    module TopMod(
    input wire clk,        // fast clock (e.g. 100 MHz)
    input wire reset,
 resetlfsr ,
    input wire [6:0] lfsr_seed,
    input wire lfsr_load,
    output signed [7:0] I_out,
    output signed [7:0] Q_out,
    output valid_out,

    // debug outputs
    output wire lfsr_bit,
    output wire encoder_v1,
    output wire encoder_v2,
    output wire serializer_out_bit,
    output wire serializer_valid,
    output wire [3:0] interleaver_out,
    output wire interleaver_valid,
    output wire lfsr_valid,
    output wire clk_slow_out
);
 reg clk_slow = 0;  
assign clk_slow_out = clk_slow;    
    always @(posedge clk or posedge reset) begin
        if (reset)
            clk_slow <= 0;
        else
            clk_slow <= ~clk_slow;
    end

    
    wire encoder_valid;

    // LFSR and convenc clocked by slow clock
    LFSR lfsr_inst (
        .clk(clk_slow),
        .reset(resetlfsr),
        .load(lfsr_load),
        .seed(lfsr_seed),
        .q(lfsr_bit),
        .valid_out(lfsr_valid)
    );

    convenc encoder_inst (
        .clk(clk_slow),
        .reset(reset),
        .load(lfsr_load),
        .seed(3'b000),
        .data(lfsr_bit),
        .v1(encoder_v1),
        .v2(encoder_v2),
        .valid_out(encoder_valid),
        .valid_in(lfsr_valid)
    );

    // Serializer, interleaver, QAM run at full fast clock
    serializer serializer_inst (
        .clk(clk),
        .reset(reset),
        .valid(encoder_valid),
        .v1(encoder_v1),
        .v2(encoder_v2),
        .out_bit(serializer_out_bit),
        .valid_out(serializer_valid)
    );

    Interleaver interleaver_inst (
        .clk(clk),
        .in_bit(serializer_out_bit),
        .load_en(serializer_valid),
        .out_bits(interleaver_out),
        .data_valid(interleaver_valid)
    );

    QAMMOD qam_inst (
        .clk(clk),
        .reset(reset),
        .data_valid(interleaver_valid),
        .in_bits(interleaver_out),
        .I_out(I_out),
        .Q_out(Q_out),
        .valid_out(valid_out)
    );

endmodule
