t(i_a) == 0)
		begin
			`ASSERT(o_r == 0);
		end else if ($past(i_a) == 1)
			`ASSERT(o_r == $past(i_b));

		if ($past(i_b) == 0)
		begin
			`ASSERT(o_r == 0);
		end else if ($past(i_b) == 1)
			`ASSERT(o_r[(LUTB-1):0] == $past(i_a));
	end
`endif

endmodule
