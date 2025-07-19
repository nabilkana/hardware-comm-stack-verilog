`timescale 1ns / 1ps

module convecut();
   reg valid_in ; 
    reg clk;
    reg reset;
    reg data;
    wire v1, v2;
    wire valid_out;
    reg load;
reg [2:0] seed;

    convenc uut (
        .clk(clk),
        .reset(reset),
        .data(data),
        .valid_in(valid_in),
        .v1(v1),
        .v2(v2),
        .valid_out(valid_out),
        .load(load),
        .seed(seed)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    reg [39:0] test_input = 40'b10110011101110001101_0001100110_1010101010; // example 30-bit binary literal

    integer i;

    initial begin
        $dumpfile("convenc.vcd");
        $dumpvars(0, convecut);
  load = 0 ;
  seed = 0 ;
   valid_in = 0 ; 
        reset = 1;

     #20 ; 
     reset = 0 ; 
       
         
     
        // Feed bits one at a time
        for (i = 0; i < 40; i = i + 1) begin
         @(posedge clk);
            data = test_input[i];
            valid_in = 1 ;
           
        end
   valid_in = 0 ; 
       
       

        #50;
        $finish;
    end

endmodule
