first_lost_bit)
                    o_val <= truncated_value;
                else if (|other_lost_bits)
                    o_val <= rounded_up;
                else if (last_valid_bit)
                    o_val <= rounded_up;
                else
                    o_val <= truncated_value;
            end
        end
    endgenerate
endmodule
