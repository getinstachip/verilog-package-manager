          ob_b_r <= n_rnd_diff_i;
                    ob_b_i <= rnd_diff_r;
                end
            end

            omem[0] <= ob_b;
            omem[1] <= omem[0];
        end

        if (i_ce) o_sync <= (iaddr[2:0] == 3'b101);
    end

endmodule
