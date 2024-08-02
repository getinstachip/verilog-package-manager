addr] == f_addr_value);

	// Make Verilator happy
	wire unused_formal;
	assign unused_formal = &{1'b0, f_reversed_addr[LGSIZE]};
`endif
endmodule
