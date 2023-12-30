`timescale 1ns / 1ps

//WR RD are generated from FSM
module Memory_Module(input[7:0]Data_in,
                     input[15:0]Address,
                     input RD,WR,
                     output reg [7:0]Data_out);
                     
    reg [7:0] Mem[0:65535];
    
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

module LFSR_TOP(input [3:0]X,input LFSR_Clock,Reset,LFSR_Enable,Compare_Found,output [15:0]LFSR_OUT);

    wire [15:0]En,LFSR_REG;
    wire [3:0]Shift_Mag;

    Enable_Signal_Decoder X1 (X,En);
    
    LFSR_16BIT X2 (LFSR_Clock,En,Reset,LFSR_Enable,Compare_Found,LFSR_REG);
    
    Shift_Mag_Calc X3 (X,Shift_Mag);
    
    Barrel_Shifter_16 X4(LFSR_REG,Shift_Mag,LFSR_OUT);
endmodule

module Enable_Signal_Decoder(input [3:0]X,output reg[15:0]Y);

    always@(*)
        begin
            case(X)
            4'b0000: Y=16'b1000_0000_0000_0000;
            4'b0001: Y=16'b1100_0000_0000_0000;
            4'b0010: Y=16'b0110_0000_0000_0000;
            4'b0011: Y=16'b0011_0000_0000_0000;
            4'b0100: Y=16'b0010_1000_0000_0000;
            4'b0101: Y=16'b0000_1100_0000_0000;
            4'b0110: Y=16'b0000_0110_0000_0000;
            4'b0111: Y=16'b0110_0011_0000_0000;
            4'b1000: Y=16'b0000_1000_1000_0000;
            4'b1001: Y=16'b0000_0010_0100_0000;
            4'b1010: Y=16'b0000_0000_1010_0000;
            4'b1011: Y=16'b0000_1001_1001_0000;
            4'b1100: Y=16'b0000_0000_1101_1000;
            4'b1101: Y=16'b0110_0000_0000_1100;
            4'b1110: Y=16'b0000_0000_0000_0110;
            4'b1111: Y=16'b0000_0000_0010_1101;
            endcase
        end
endmodule

module LFSR_16BIT #(parameter seed=16'b1000_0000_0000_0000)
                  (input LFSR_Clock,input [15:0]En,input Reset,LFSR_Enable,Compare_Found,
                   output reg [15:0]LFSR_REG);
wire f;
wire [15:0]AND_OUT;

initial LFSR_REG <= seed;

always@(posedge LFSR_Clock or posedge Reset or posedge Compare_Found)
begin
    if(Reset)                           //reset
        LFSR_REG <= seed;
    else if(LFSR_Enable)
    begin
        if (Compare_Found == 1'b1)         //normal op
            LFSR_REG <= LFSR_REG;
        //data match occurs here
        else
            LFSR_REG[15:0]<={f,LFSR_REG[15:1]};
   end
    else
        // LFSR_REG <= seed;
        LFSR_REG <= LFSR_REG;      
    
end

generate
	genvar i;
	for (i = 0; i < 16; i = i + 1)
	begin:LFSR
		assign AND_OUT[i] = LFSR_REG[i]&En[i]; 
	end
endgenerate

assign f = ^AND_OUT;

endmodule

module Shift_Mag_Calc(input[3:0]X,output[3:0]Shift_Mag);
    assign Shift_Mag=4'b1111-X;
endmodule

module Mux2_1(input I1,I0,S,output O);
    assign O = S?I1:I0;
endmodule

module Barrel_Shifter_16(input[15:0]Inp,
                         input[3:0]Shift_Mag,
                         output[15:0]Outp);
    
	wire [15:0]S1,S2,S3;

    //Stage 1 - 1 Bit Shifting
    Mux2_1 Stage1_15(1'b0,Inp[15],Shift_Mag[0],S1[15]);

    generate
    	genvar i;
    	for (i = 0; i <=14; i = i + 1)
    	begin:Stage1
    		Mux2_1 Stage1(Inp[i+1],Inp[i],Shift_Mag[0],S1[i]);
    	end
    endgenerate

    //Stage 2 - 2 Bit Shifting

    Mux2_1 Stage2_15(1'b0,S1[15],Shift_Mag[1],S2[15]);
    Mux2_1 Stage2_14(1'b0,S1[14],Shift_Mag[1],S2[14]);

     generate
   
    	for (i = 0; i <=13; i = i + 1)
    	begin:Stage2
    		Mux2_1 Stage2(S1[i+2],S1[i],Shift_Mag[1],S2[i]);
    	end
    endgenerate

    //Stage 3 - 4 Bit Shifting

	Mux2_1 Stage3_15(1'b0,S2[15],Shift_Mag[2],S3[15]);
    Mux2_1 Stage3_14(1'b0,S2[14],Shift_Mag[2],S3[14]);
    Mux2_1 Stage3_13(1'b0,S2[13],Shift_Mag[2],S3[13]);
    Mux2_1 Stage3_12(1'b0,S2[12],Shift_Mag[2],S3[12]);
	 generate
	 
	    	for (i = 0; i <=11; i = i + 1)
	    	begin:Stage3
	    		Mux2_1 Stage3(S2[i+4],S2[i],Shift_Mag[2],S3[i]);
	    	end
	    endgenerate

    //Stage 4 - 8 Bit Shifting

    generate
    
    	for (i = 0; i < 8; i = i + 1)
    	begin:Stage4_0_7
    		Mux2_1 Stage4(S3[i+8],S3[i],Shift_Mag[3],Outp[i]);
    	end
    endgenerate

 	generate
    
    	for (i = 8; i <=15; i = i + 1)
    	begin:Stage4_8_15
    		Mux2_1 Stage4(1'b0,S3[i],Shift_Mag[3],Outp[i]);
    	end
    endgenerate
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

module PEncoder16_4(input [15:0] input_data, output reg [3:0] ouput_data);
    
    always @(*)
    begin
        if(input_data[15] == 1) ouput_data = 4'b1111;
        else if(input_data[14] == 1) ouput_data = 4'b1110;
        else if(input_data[13] == 1) ouput_data = 4'b1101;
        else if(input_data[12] == 1) ouput_data = 4'b1100;
        else if(input_data[11] == 1) ouput_data = 4'b1011;
        else if(input_data[10] == 1) ouput_data = 4'b1010;
        else if(input_data[9] == 1) ouput_data = 4'b1001;
        else if(input_data[8] == 1) ouput_data = 4'b1000;
        else if(input_data[7] == 1) ouput_data = 4'b0111;
        else if(input_data[6] == 1) ouput_data = 4'b0110;
        else if(input_data[5] == 1) ouput_data = 4'b0101;
        else if(input_data[4] == 1) ouput_data = 4'b0100;
        else if(input_data[3] == 1) ouput_data = 4'b0011;
        else if(input_data[2] == 1) ouput_data = 4'b0010;
        else if(input_data[1] == 1) ouput_data = 4'b0001;
        else if(input_data[0] == 1) ouput_data = 4'b0000;
        else    ouput_data = 4'b0000;
    end

endmodule

module Compare_Found_Result(input Compare_Found, output Compare_Found_Out);
	assign Compare_Found_Out = Compare_Found;
endmodule

module top_module_LFSR(  input[7:0] Data_in,
                    input RD_Ext,WR_Ext,
                    input Clock, Clock_LFSR,
                    input [15:0] WR_Count,
                    output [15:0] Address_out,
                    output Compare_Found_Out
                    );
    
    wire RD, WR, Temp_Trigger, LFSR_Enable, LFSR_Reset, Data_Compare_Enable;    //Controlpath outputs
    wire Compare_Found;
    wire [3:0] P_Encode_Out;    //To select degree of LFSR
    wire [15:0] LFSR_Out;       //Random addresses generated
    wire [15:0] Address;         //Address to go to memory
    wire [7:0] Mem_Data;        //Data that comes from memory and gets compared
    wire [7:0] Temp;            //Output of Temp_read and input of Data_compare
    
    Memory_Module X1(.Data_in(Data_in), .Address(LFSR_Out), .RD(RD), .WR(WR), .Data_out(Mem_Data));
    
    ControlPath X2( .WR_Ext(WR_Ext), .RD_Ext(RD_Ext), .Clock(Clock), .Compare_Found(Compare_Found),
                    .RD(RD), .WR(WR), .Temp_Trigger(Temp_Trigger), .LFSR_Enable(LFSR_Enable),
                    .LFSR_Reset(LFSR_Reset), .Data_Compare_Enable(Data_Compare_Enable));
    
    LFSR_TOP X3(.X(P_Encode_Out), .LFSR_Clock(Clock_LFSR), .Reset(LFSR_Reset),.LFSR_Enable(LFSR_Enable),
                .Compare_Found(Compare_Found), .LFSR_OUT(LFSR_Out));
    
    Data_Compare X4(.Temp(Temp), .Mem_Data(Mem_Data), .enable(Data_Compare_Enable), .Compare_Found(Compare_Found));
                     
    Temp_Read X7(.Trigger(Temp_Trigger), .Data_In(Data_in), .Temp(Temp));          
    
    Output_Address X8(.LFSR_OUT(LFSR_Out),.Output_Trigger(Compare_Found), .Address(Address_out));

    PEncoder16_4 X9 (.input_data(WR_Count),.ouput_data(P_Encode_Out));

    Compare_Found_Result X10(.Compare_Found(Compare_Found), .Compare_Found_Out(Compare_Found_Out));
    
endmodule
