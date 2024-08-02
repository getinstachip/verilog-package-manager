     last_q <= 'd0;
        end else if (!en_i) begin
            data_q <= 'd0;
            valid_q <= 'd0;
            last_q <= 'd0;
        end else if (valid) begin
            data_q <= data;
            valid_q <= valid;
            last_q <= last;
        end else begin
            data_q <= 'd0;
            valid_q <= 'd0;
            last_q <= 'd0;
        end
    end


    assign data_o = data_q;
    assign valid_o = valid_q;
    assign last_o = last_q;

    // No waveform script

endmodule
