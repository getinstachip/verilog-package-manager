module decimatorFFT #(parameter IWIDTH = 16, OWIDTH = IWIDTH + 1, LGWIDTH = 8, INVERSE = 0, SHIFT = 0) (
    input wire i_clk, i_reset, i_ce, i_sync,
    input wire [(2*IWIDTH-1):0] i_data,
    output reg [(2*OWIDTH-1):0] o_data,
    output reg o_sync
);

    reg wait_for_sync;
    reg [2:0] pipeline;
    reg signed [IWIDTH:0] sum_r, sum_i, diff_r, diff_i;
    reg [(2*OWIDTH-1):0] ob_a;
    wire [(2*OWIDTH-1):0] ob_b;
    reg [(OWIDTH-1):0] ob_b_r, ob_b_i;
    assign ob_b = {ob_b_r, ob_b_i};

    reg [(LGWIDTH-1):0] iaddr;
    reg [(2*IWIDTH-1):0] imem[0:1];

    wire signed [(IWIDTH-1):0] imem_r = imem[1][(2*IWIDTH-1):IWIDTH];
    wire signed [(IWIDTH-1):0] imem_i = imem[1][(IWIDTH-1):0];
    wire signed [(IWIDTH-1):0] i_data_r = i_data[(2*IWIDTH-1):IWIDTH];
    wire signed [(IWIDTH-1):0] i_data_i = i_data[(IWIDTH-1):0];

    reg [(2*OWIDTH-1):0] omem[0:1];

    wire signed [(OWIDTH-1):0] rnd_sum_r, rnd_sum_i, rnd_diff_r, rnd_diff_i;
    wire signed [(OWIDTH-1):0] n_rnd_diff_r = -rnd_