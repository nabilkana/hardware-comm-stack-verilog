
module TopMod2 (
    input clk,
    input reset,
    input [3:0] file_in_bits,
    input data_ready,
    output wire [61:0] decoded_data,
    output wire decoded_valid,

    // Added outputs for monitoring
    output wire deint_out,
    output wire deint_out_valid,
    output wire [1:0] vitebri_data_in,
    output wire vitebri_valid_in,
    
    output wire [2:0] vitebri_state,
output wire [8:0] vitebri_counter,
output wire [15:0] PM0_debug,
output wire [15:0] PM1_debug
);

    wire deint_data_out;
    wire deint_out_ready;

    deinterleaver deinterleaver_inst (
        .clk(clk),
        .reset(reset),
        .in_bits(file_in_bits),
        .data_ready(data_ready),
        .data_out(deint_data_out),
        .out_ready(deint_out_ready)
    );

    // Assign internal signals to output ports
    assign deint_out = deint_data_out;
    assign deint_out_valid = deint_out_ready;

    wire [1:0] internal_vitebri_data_in;
    wire internal_vitebri_valid_in;

    // Instantiate serial_to_pair
    serial_to_pair u_serial_to_pair (
        .clk(clk),
        .reset(reset),
        .deint_out(deint_data_out),
        .deint_out_valid(deint_out_ready),
        .vitebri_data_in(internal_vitebri_data_in),
        .vitebri_valid_in(internal_vitebri_valid_in)
    );

    // Connect internal serial_to_pair outputs to module outputs
    assign vitebri_data_in = internal_vitebri_data_in;
    assign vitebri_valid_in = internal_vitebri_valid_in;

    // Instantiate Viterbi decoder
    vitebri vitebri_inst (
        .clk(clk),
        .reset(reset),
        .data_in(vitebri_data_in),
        .valid_input(vitebri_valid_in),
        .data_out(decoded_data),
        .valid_output(decoded_valid),
         .stt(vitebri_state),
    .coun(vitebri_counter),
    .PM0_debug(PM0_debug),
    .PM1_debug(PM1_debug)
    );

endmodule
