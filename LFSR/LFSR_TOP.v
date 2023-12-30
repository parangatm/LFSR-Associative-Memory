`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.05.2020 10:46:43
// Design Name: 
// Module Name: LFSR_TOP
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

                   
module LFSR_TOP(input [3:0]X,input LFSR_Clock,Reset,LFSR_Enable,Compare_Found,output [15:0]LFSR_OUT);

    wire [15:0]En,LFSR_REG;
    wire [3:0]Shift_Mag;
 
    Enable_Signal_Decoder X1 (X,En);
    LFSR_16BIT X2 (LFSR_Clock,En,Reset,LFSR_Enable,Compare_Found,LFSR_REG);
    Shift_Mag_Calc X3 (X,Shift_Mag);
    Barrel_Shifter_16 X4(LFSR_REG,Shift_Mag,LFSR_OUT);
  
endmodule
