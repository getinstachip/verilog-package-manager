 f_const_addr[LGSIZE];


	always @(posedge i_clk or posedge i_reset) begin
		if (i_reset)
			f_addr_loaded <= 1'b0;
		else if (i_ce) begin
			if (wraddr == f_const_addr)
				f_addr_loaded <= 1'b1;
			else if (rdaddr == f_const_addr)
				f_addr_loaded <= 1'b0;
		end
	end


	always @(posedge i_clk)
	if (i_ce && (wraddr == f_const_addr))
		f_addr_value <= i_in;

	always @(posedge i_clk)
	if (f_past_valid && !$past(i_reset) && $past(f_addr_loaded) && !f_addr_loaded)
		`ASSERT(o_out == f_addr_value);

	always @(*)
	if (o_sync)
		`ASSERT(wraddr[LGSIZE-1:0] == 1);

	always @(*)
	if (wraddr[LGSIZE] == f_const_addr[LGSIZE] && wraddr[LGSIZE-1:0] <= f_const_addr[LGSIZE-1:0])
		`ASSERT(!f_addr_loaded);

	always @(*)
	if (rdaddr[LGSIZE] == f_const_addr[LGSIZE] && f_addr_loaded)
		`ASSERT(wraddr[LGSIZE-1:0] <= f_reversed_addr[LGSIZE-1:0] + 1);

	always @(*)
	if (f_addr_loaded)
		`ASSERT(brmem[f_const_addr] == f_addr_value);

	// Make Verilator happy
	wire unused_formal;
	assign unused_formal = &{1'b