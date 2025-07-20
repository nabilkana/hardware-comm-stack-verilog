`timescale 1ns / 1ps

module tb_TopModut();

    reg clk = 0;
    reg reset = 1;
    reg lfsr_load = 0;
    reg [6:0] lfsr_seed = 7'b1010101;

    wire signed [7:0] I_out;
    wire signed [7:0] Q_out;
    wire valid_out;

    // Instantiate your top module
    TopModut uut (
        .clk(clk),
        .reset(reset),
        .lfsr_seed(lfsr_seed),
        .lfsr_load(lfsr_load),
        .I_out(I_out),
        .Q_out(Q_out),
        .valid_out(valid_out)
    );

    // Clock generation: 10 ns period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Initial reset pulse
        #10;
        reset = 0;
        lfsr_load = 1; // Load LFSR seed
        #10;
        lfsr_load = 0; // Release load, start operation

        // Run for enough cycles to process all bits + flushing
        #(256 * 20); // adjust as needed

        $finish;
    end

   
    always @(posedge clk) begin
        if (valid_out) begin
            $display("Time %0t: I_out = %d, Q_out = %d", $time, I_out, Q_out);
        end
    end

endmodule
