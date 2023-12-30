`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.05.2020 10:23:15
// Design Name: 
// Module Name: Memory_Top
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

module top(  input[7:0] Data_in,
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
    wire [15:0] Address;        //Address to go to memory
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
