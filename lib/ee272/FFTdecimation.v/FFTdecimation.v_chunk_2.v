n
                iaddr <= iaddr + 1'b1;
                wait_for_sync <= 1'b0;
            end
            imem[0] <= i_data;
            imem[1] <= imem[0];

            if (iaddr[1]) begin
                sum_r  <= imem_r + i_data_r;
                sum_i  <= imem_i + i_data_i;
                diff_r <= imem_r - i_data_r;
                diff_i <= imem_i - i_data_i;
            end

            pipeline <= {pipeline[1:0], iaddr[1]};

            if (pipeline[2]) o_data <= ob_a;
            else o_data <= omem[1];

            if (iaddr[1]) begin
                ob_a <= {rnd_sum_r, rnd_sum_i};
                if (!iaddr[0]) begin
                    ob_b_r <= rnd_diff_r;
                    ob_b_i <= rnd_diff_i;
                end else if (INVERSE == 0) begin
                    ob_b_r <= rnd_diff_i;
                    ob_b_i <= n_rnd_diff_r;
                end else begin
                    ob_b_r <= n_rnd_diff_i;
                    ob_b_i <= rnd_diff_r;
                end
    