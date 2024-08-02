'b0}}, 1'b1};
            wire last_valid_bit = truncated_value[0];
            wire first_lost_bit = i_val[0];

            always @(posedge i_clk) if (i_ce) begin
                if (!first_lost_bit)
                    o_val <= truncated_value;
                else if (last_valid_bit)
                    o_val <= rounded_up;
                else
                    o_val <= truncated_value;
            end
        end
        else begin : ROUND_RESULT
            wire [OWID-1:0] truncated_value = i_val[IWID-1-SHIFT:IWID-SHIFT-OWID];
            wire [OWID-1:0] rounded_up = truncated_value + {{(OWID-1){1'b0}}, 1'b1};
            wire last_valid_bit = truncated_value[0];
            wire first_lost_bit = i_val[IWID-SHIFT-OWID-1];
            wire [IWID-SHIFT-OWID-2:0] other_lost_bits = i_val[IWID-SHIFT-OWID-2:0];

            always @(posedge i_clk) if (i_ce) begin
                if (!first_lost_bit)
                    o_val <= truncated_value;
                else if (|other_lost_b