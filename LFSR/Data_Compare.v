`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2020 09:56:26
// Design Name: 
// Module Name: Data_Compare
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
