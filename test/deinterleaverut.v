`timescale 1ns / 1ps

module deinterleaverut;

    reg clk;
    reg reset ;
    reg data_ready;
    wire out_ready ; 
    reg [3:0] in_bits;
    wire data_out;

    deinterleaver uut (
        .clk(clk),
        .reset(reset) ,
        .out_ready(out_ready),
        .data_ready(data_ready),
        .in_bits(in_bits),
        .data_out(data_out)
    );

    reg [127:0] test_data = 128'h3C3C_C3C3_CCCC_3333_C5AC_368C_0DDE_3EFC;
    integer i;

    initial clk = 0;
    always #5 clk = ~clk;  

    initial begin
        $dumpfile("deinterleaver.vcd");
        $dumpvars(0, deinterleaverut);
         reset = 1 ; 
        data_ready = 0;
        
        #10;

        for (i = 0; i < 128; i = i + 4) begin
            @(posedge clk);
            in_bits[3] = test_data[127 - i];
            in_bits[2] = test_data[126 - i];
            in_bits[1] = test_data[125 - i];
            in_bits[0] = test_data[124 - i];
            data_ready = 1;
            reset = 0 ; 
        end
        @(posedge clk);
  data_ready = 0 ; 
  #1500;
        for (i = 0; i < 128; i = i + 4) begin
            @(posedge clk);
            in_bits[3] = test_data[127 - i];
            in_bits[2] = test_data[126 - i];
            in_bits[1] = test_data[125 - i];
            in_bits[0] = test_data[124 - i];
            data_ready = 1;
            reset = 0 ; 
        end
        @(posedge clk);
  data_ready = 0 ; 
  #10000;

        $finish;
    end

endmodule
