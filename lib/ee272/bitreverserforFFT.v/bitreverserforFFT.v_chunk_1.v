raddr <= wraddr + 1;
		end
	end


	always @(posedge i_clk) begin
		if (i_ce)
			o_out <= brmem[rdaddr];
	end


	always @(posedge i_clk or posedge i_reset) begin
		if (i_reset)
			o_sync <= 1'b0;
		else if (i_ce && !in_reset)
			o_sync <= (wraddr[LGSIZE-1:0] == 0);
	end

`ifdef FORMAL
`define ASSERT assert
`define ASSUME assume

	reg f_past_valid;
	initial f_past_valid = 1'b0;
	always @(posedge i_clk)
		f_past_valid <= 1'b1;

	initial `ASSUME(i_reset);

	always @(posedge i_clk)
	if ((!f_past_valid) || ($past(i_reset))) begin
		`ASSERT(wraddr == 0);
		`ASSERT(in_reset);
		`ASSERT(!o_sync);
	end

	(* anyconst *) reg [LGSIZE:0] f_const_addr;
	wire [LGSIZE:0] f_reversed_addr;
	reg f_addr_loaded;
	reg [(2*WIDTH-1):0] f_addr_value;


	generate 
		for (k = 0; k < LGSIZE; k = k + 1) begin
			assign f_reversed_addr[k] = f_const_addr[LGSIZE-1-k];
		end
	endgenerate
	assign f_reversed_addr[LGSIZE] = f_const_addr[LGSIZE];


	always @(posedge i_clk or posedge i_reset) begin
		if (i_reset)
			f_addr_