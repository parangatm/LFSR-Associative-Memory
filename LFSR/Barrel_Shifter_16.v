`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.05.2020 13:19:38
// Design Name: 
// Module Name: Barrel_Shifter_16
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
