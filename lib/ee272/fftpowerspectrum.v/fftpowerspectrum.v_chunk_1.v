d_i_q <= 'd0;
            last_i_q <= 'd0;
        end else if (!en_i) begin
            data_i_q <= 'd0;
            valid_i_q <= 'd0;
            last_i_q <= 'd0;
        end else if (valid_i) begin
            data_i_q <= data_i;
            valid_i_q <= valid_i;
            last_i_q <= last_i;
        end else begin
            data_i_q <= 'd0;
            valid_i_q <= 'd0;
            last_i_q <= 'd0;
        end
    end


    wire signed [I_BW - 1 : 0] real_i = data_i_q[I_BW * 2 - 1 : I_BW];
    wire signed [I_BW - 1 : 0] imag_i = data_i_q[I_BW - 1 : 0];

    wire [O_BW - 1 : 0] data = (real_i * real_i) + (imag_i * imag_i);
    wire valid = valid_i_q;
    wire last = last_i_q;

    reg [O_BW - 1 : 0] data_q;
    reg valid_q;
    reg last_q;
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            data_q <= 'd0;
            valid_q <= 'd0;
            last_q <= 'd0;
        end else if (!en_i) begin
            data_q <= 'd0;
            valid_q