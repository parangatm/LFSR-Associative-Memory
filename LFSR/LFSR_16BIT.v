`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.05.2020 20:34:52
// Design Name: 
// Module Name: LFSR_16BIT
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
