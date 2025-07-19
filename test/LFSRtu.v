`timescale 1ns / 1ps

module LFSRtu();
    reg clk = 0;
    reg reset = 1;
    reg load = 0;
    reg [6:0] seed = 7'b1010101;
    wire q;
    wire valid_out;

    LFSR uut (
        .clk(clk),
        .reset(reset),
        .load(load),
        .seed(seed),
        .q(q),
        .valid_out(valid_out)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("LFSR.vcd");
        $dumpvars(0, LFSRtu);

        #20;
        reset = 0;

        // Load seed
        load = 1;
        #10;
        load = 0;

        wait(valid_out == 0);

        #20;
        $finish;
    end
endmodule
