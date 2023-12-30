`timescale 1ns / 1ps

module Memory_Module(input[7:0]Data_in,
                     input[15:0]Address,
                     input RD,WR,
                     output reg [7:0]Data_out);
                     
    reg [15:0] Mem[0:65535];
    
    always@(Address)
        begin
            if(WR==1 & RD==0)
                Mem[Address]<=Data_in;
            else if (RD==1 & WR==0)
                Data_out<=Mem[Address];
        end

    initial $readmemh("mem_init_8_bits.txt", Mem);
endmodule

module ControlPath(input WR_Ext,RD_Ext,Clock,Compare_Found,
				   output reg RD,WR,Temp_Trigger,LFSR_Enable,LFSR_Reset,Data_Compare_Enable);
	
	parameter Start=3'b000,Write=3'b001,Temp=3'b010,LFSR=3'b011;
 
	reg [2:0]State=3'b000;
	reg [2:0]Next_State=3'b000;
	reg [5:0]Control_Vector;

	always @(posedge Clock) 
		begin
			case(State)
                Start:
                    begin
                        if(WR_Ext==1)
                            Next_State=Write;
                        else if(RD_Ext==1)
                            Next_State=Temp;
                        else
                            Next_State=Start;
                    end
                Write:
                    Next_State=Start;		
                Temp:
                    Next_State=LFSR;
                LFSR:
                    begin		
                        if (Compare_Found==1) 
                            Next_State=Start;
                        else 
                            Next_State=LFSR;							
                    end
                default:
                    Next_State=Start;
		    endcase
	    end
	
	always@(State)
	    begin
	        case(State)
                Start:
                    Control_Vector<=6'b000000;
                Write:
                    Control_Vector<=6'b010000;		
                Temp:
                    Control_Vector<=6'b001000;
                LFSR:
                    Control_Vector<=6'b100101;
                default:
                    Control_Vector<=6'b000000;
	       endcase
	    end
	
	
	always@(Control_Vector)
	begin
	   {RD,WR,Temp_Trigger,LFSR_Enable,LFSR_Reset,Data_Compare_Enable}=Control_Vector;
	end
	 
    always@(posedge Clock)	// State Assignment
			 begin 
				 State = Next_State;
			 end  
endmodule

module counter_top(input LFSR_Clock,Count_Reset,Count_Enable,Compare_Found,output reg[15:0]Count);
      
        always@(posedge LFSR_Clock or posedge Count_Reset or posedge Compare_Found)
            begin
                if(Count_Reset)                           //reset
                    Count<=16'b0;
        
            else if(Count_Enable)
                    begin
                        if (Compare_Found == 1'b1)         //normal op
                            Count<=Count;
                        else
                            Count<=Count+1;
               
                   end
            else
                Count<=16'b0;      
    
            end
endmodule

module Data_Compare(input[7:0]Temp,Mem_Data,input enable,output Compare_Found);
    
    wire[7:0] T;

    generate
    	genvar i;
    	for (i = 0; i < 8; i = i + 1)
    	begin:identifier
    		
    		assign T[i] = Temp[i] ^ Mem_Data[i]; 

    	end
    endgenerate
     
    assign Compare_Found =(enable)& ((|T) ? 1'b0:1'b1);

endmodule

module Temp_Read(input Trigger, input[7:0] Data_In, output reg[7:0] Temp);

    always@(posedge Trigger)
        Temp<=Data_In;

endmodule

module Output_Address(input[15:0]LFSR_OUT,input Output_Trigger,output reg[15:0]Address);

    always@(posedge Output_Trigger)
        begin
        	if(Output_Trigger)
        		Address=LFSR_OUT;	
        end
        
endmodule

module Compare_Found_Result(input Compare_Found, output Compare_Found_Out);
	assign Compare_Found_Out = Compare_Found;
endmodule

module top_module_counter(  input[7:0] Data_in,
                    input RD_Ext,WR_Ext,
                    input Clock, Clock_LFSR,
                    output [15:0] Address_out,
                    output Compare_Found_Out
                    );
    
    wire RD, WR, Temp_Trigger, Count_Enable, Count_Reset, Data_Compare_Enable;    //Controlpath outputs
    wire Compare_Found;
   
    wire [15:0] Counter_Out;         //Address to go to memory
    wire [7:0] Mem_Data;        //Data that comes from memory and gets compared
    wire [7:0] Temp;            //Output of Temp_read and input of Data_compare
    
    Memory_Module X1(.Data_in(Data_in), .Address(Counter_Out), .RD(RD), .WR(WR), .Data_out(Mem_Data));
    
    ControlPath X2( .WR_Ext(WR_Ext), .RD_Ext(RD_Ext), .Clock(Clock), .Compare_Found(Compare_Found),
                    .RD(RD), .WR(WR), .Temp_Trigger(Temp_Trigger), .LFSR_Enable(Count_Enable),
                    .LFSR_Reset(Count_Reset), .Data_Compare_Enable(Data_Compare_Enable));
    
    counter_top X3( .LFSR_Clock(Clock_LFSR), .Count_Reset(Count_Reset),.Count_Enable(Count_Enable),
                    .Compare_Found(Compare_Found), .Count(Counter_Out));

    Data_Compare X4(.Temp(Temp), .Mem_Data(Mem_Data), .enable(Data_Compare_Enable), .Compare_Found(Compare_Found));
                 
    Temp_Read X7(.Trigger(Temp_Trigger), .Data_In(Data_in), .Temp(Temp));          
    
    Output_Address X8(.LFSR_OUT(Counter_Out),.Output_Trigger(Compare_Found), .Address(Address_out));

    Compare_Found_Result X10(.Compare_Found(Compare_Found), .Compare_Found_Out(Compare_Found_Out));
endmodule
