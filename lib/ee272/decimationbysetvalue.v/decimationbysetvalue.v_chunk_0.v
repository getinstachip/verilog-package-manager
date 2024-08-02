module decimator #(
    parameter DATA_BW = 8,
    parameter DECIM_FACTOR = 250
) (
    // clock and reset
    input                       clk_i,
    input                       rst_n_i,

    // streaming input
    input                       en_i,
    input [DATA_BW - 1 : 0]     data_i,
    input                       valid_i,

    // streaming output
    output [DATA_BW - 1 : 0]    data_o,
    output                      valid_o
);

    localparam COUNTER_BW = $clog2(DECIM_FACTOR);

    reg [COUNTER_BW - 1 : 0] counter;  // counts from 0 to DECIM_FACTOR-1
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            counter <= 'd0;
        end else if (!en_i) begin
            counter <= 'd0;
        end else if (valid_i) begin
            if (counter == DECIM_FACTOR - 1) begin
                counter <= 'd0;
            end else begin
                counter <= counter + 'd1;
            end
        end
    end
    
    assign data_o  = data_i;
    ass