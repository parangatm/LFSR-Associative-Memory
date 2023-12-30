`timescale 1ns / 1ps

module test_LFSR();
	reg [7:0] Data_in;
	reg RD_Ext, WR_Ext, Clock, Clock_LFSR;
	reg [15:0] WR_Count;
	wire [15:0] Address_out;
	wire Compare_Found_Out;

	reg [7:0] test_memory[0:255];

	integer i,f;

	reg [15:0] search_count = 16'b0;

	initial $readmemh("mem_test_8_bits.txt", test_memory);

	initial
		begin
			Clock = 1'b0;
			Clock_LFSR = 1'b0;
		end

	initial
		begin
			WR_Count = 16'h00FF;
			WR_Ext = 1'b0;
			RD_Ext = 1'b0;
			Data_in = 8'b0;
			#650;
			for(i=0; i<255; i=i+1)
			begin
			 	Data_in = test_memory[i];
			 	RD_Ext = 1'b1;
			 	wait(!Clock);
				wait(Clock);
				wait(!Clock);
				wait(Clock);
				wait(!Clock);
				RD_Ext = 1'b0;
			 	wait(Compare_Found_Out);
				wait(!Compare_Found_Out);
				#600;
			 end
			#200;
			$finish;
		end
	always #1 Clock_LFSR = ~Clock_LFSR;
	always #100 Clock = ~Clock;

	always @(Address_out)
	begin
		search_count = search_count + 1;
		$display($time, " Data_in: %h found successfully at %d Search #%d", Data_in, Address_out, search_count);
	end

	always @(posedge Clock)
	begin
		if(RD_Ext == 1'b1)
			begin
				$display($time, " Data_in: %h search operation started", Data_in);
			end
	end
	
	top_module_lfsr UUT(Data_in, RD_Ext, WR_Ext, Clock, Clock_LFSR, WR_Count, Address_out, Compare_Found_Out);

endmodule
