0] rnd_sum_r, rnd_sum_i, rnd_diff_r, rnd_diff_i;
    wire signed [(OWIDTH-1):0] n_rnd_diff_r = -rnd_diff_r;
    wire signed [(OWIDTH-1):0] n_rnd_diff_i = -rnd_diff_i;

    convround #(IWIDTH+1, OWIDTH, SHIFT) do_rnd_sum_r(i_clk, i_ce, sum_r, rnd_sum_r);
    convround #(IWIDTH+1, OWIDTH, SHIFT) do_rnd_sum_i(i_clk, i_ce, sum_i, rnd_sum_i);
    convround #(IWIDTH+1, OWIDTH, SHIFT) do_rnd_diff_r(i_clk, i_ce, diff_r, rnd_diff_r);
    convround #(IWIDTH+1, OWIDTH, SHIFT) do_rnd_diff_i(i_clk, i_ce, diff_i, rnd_diff_i);

    initial begin
        wait_for_sync = 1'b1;
        iaddr = 0;
        pipeline = 3'h0;
        o_sync = 1'b0;
    end

    always @(posedge i_clk) begin
        if (i_reset) begin
            wait_for_sync <= 1'b1;
            iaddr <= 0;
            pipeline <= 3'h0;
            o_sync <= 1'b0;
        end else if (i_ce) begin
            if (!wait_for_sync || i_sync) begin
                iaddr <= iaddr + 1'b1;
                wait_for_sync <= 1'b0;
            end
    