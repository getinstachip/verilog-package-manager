module power_spectrum #(
// Spectrum of frequency domain signal, post time domain transformation
    parameter I_BW = 21,
    parameter O_BW = 32
) (
    // clock and reset
    input                                   clk_i,
    input                                   rst_n_i,
    input                                   en_i,

    // streaming input
    input  signed [I_BW * 2 - 1 : 0]        data_i,
    input                                   valid_i,
    input                                   last_i,

    // streaming output
    output [O_BW - 1 : 0]                   data_o,
    output                                  valid_o,
    output                                  last_o
);

    reg signed [I_BW * 2 - 1 : 0] data_i_q;
    reg valid_i_q;
    reg last_i_q;
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            data_i_q <= 'd0;
            valid_i_q <= 'd0;
            last_i_q <= 'd0;
        end else if (!en_i) begin
            data_i_q <=