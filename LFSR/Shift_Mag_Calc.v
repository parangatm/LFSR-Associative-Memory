`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.05.2020 22:26:32
// Design Name: 
// Module Name: Shift_Mag_Calc
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


module Shift_Mag_Calc(input[3:0]X,output[3:0]Shift_Mag);

    assign Shift_Mag=4'b1111-X;

endmodule
