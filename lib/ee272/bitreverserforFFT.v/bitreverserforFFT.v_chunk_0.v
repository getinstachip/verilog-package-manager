// module NOT VERIFIED, SYNTHESIZED, OR SIMULATED

module bitreverse #(
	parameter LGSIZE = 5, 
	parameter WIDTH = 24
) (
	input  wire               i_clk, i_reset, i_ce,
	input  wire [(2*WIDTH-1):0] i_in,
	output reg  [(2*WIDTH-1):0] o_out,
	output reg                o_sync
);


	reg  [(LGSIZE):0] wraddr;
	wire [(LGSIZE):0] rdaddr;
	reg  [(2*WIDTH-1):0] brmem [0:((1<<(LGSIZE+1))-1)];
	reg in_reset;

	// Bit-reverse read address
	genvar k;
	generate 
		for (k = 0; k < LGSIZE; k = k + 1) begin : BITREV
			assign rdaddr[k] = wraddr[LGSIZE-1-k];
		end
	endgenerate
	assign rdaddr[LGSIZE] = !wraddr[LGSIZE];


	always @(posedge i_clk or posedge i_reset) begin
		if (i_reset)
			in_reset <= 1'b1;
		else if (i_ce && &wraddr[LGSIZE-1:0])
			in_reset <= 1'b0;
	end


	always @(posedge i_clk or posedge i_reset) begin
		if (i_reset)
			wraddr <= 0;
		else if (i_ce) begin
			brmem[wraddr] <= i_in;
			wraddr <= wraddr + 1;
		end
	end


	always @(posedge i_clk) begin
		if (i_ce)
			o_out <= brmem[rdadd