`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2020 22:16:39
// Design Name: 
// Module Name: Temp_Read
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


module Temp_Read(input Trigger, input[7:0] Data_In, output reg[7:0] Temp);

    always@(posedge Trigger)
        Temp<=Data_In;

endmodule
