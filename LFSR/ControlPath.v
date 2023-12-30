`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2020 11:58:30
// Design Name: 
// Module Name: ControlPath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//WR_Ext RD_Ext - User given RD and WR pulse signals
//WR RD - FSM genertaed to be used for enable and selection

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
