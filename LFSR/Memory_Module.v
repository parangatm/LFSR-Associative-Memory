`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2020 09:44:02
// Design Name: 
// Module Name: Memory_Module
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
