module shiftr
#(parameter n=3)
(
    input data, 
    input [n-1:0] seed,
    input clk, 
    input load, 
    input reset, 
    output [n-1:0] q
);
    genvar k; 
    wire [n-1:0] d_in;
    wire [n-1:0] ffout;

    // Mux inputs for flip-flops: seed if load=1, else normal shift/serial input
    assign d_in[0] = load ? seed[0] : data;

    generate
        for (k = 1; k < n; k = k + 1) begin : input_mux
            assign d_in[k] = load ? seed[k] : ffout[k - 1];
        end
    endgenerate

    // First flip-flop
    dflipflop #(1) ff0 (
        .clk(clk),
        .reset(reset),
        .d(d_in[0]),
        .q(ffout[0])
    );

    // Remaining flip-flops
    generate
        for (k = 1; k < n; k = k + 1) begin : flipflops
            dflipflop #(1) ff (
                .clk(clk),
                .reset(reset),
                .d(d_in[k]),
                .q(ffout[k])
            );
        end
    endgenerate

    assign q = ffout;

endmodule
