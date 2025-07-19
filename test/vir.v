`timescale 1ns / 1ps
module vir();

    reg reset;
    reg clk;
    reg valid_input;
    reg [1:0] data_in;
    wire valid_output;
    wire [61:0] data_out;
    wire [2:0] stt;        
    wire [9:0] coun;
    wire [1:0] humm;
    wire [2:0] min;        
    wire path;

    wire [15:0] PM0_debug;
    wire [15:0] PM1_debug;
    wire [15:0] PM2_debug;
    wire [15:0] PM3_debug;
    

    
    vitebri uut (
        .reset(reset),
        .data_in(data_in),
        .data_out(data_out),
        .valid_output(valid_output),
        .valid_input(valid_input),
        .clk(clk),

        .coun(coun),
        .stt(stt),
        .humm(humm),
        .min(min),
        .path(path),

        .PM0_debug(PM0_debug),
        .PM1_debug(PM1_debug),
        .PM2_debug(PM2_debug),
        .PM3_debug(PM3_debug)
       
    );

    integer i;

 
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("viterbi.vcd");
        $dumpvars(0, vir);
    end

    reg [1:0] test_vector [0:63];

    initial begin

test_vector[0] = 2'b11;
test_vector[1] = 2'b10;
test_vector[2] = 2'b11;
test_vector[3] = 2'b11;
test_vector[4] = 2'b01;
test_vector[5] = 2'b10;
test_vector[6] = 2'b01;
test_vector[7] = 2'b00;
test_vector[8] = 2'b10;
test_vector[9] = 2'b00;
test_vector[10] = 2'b01;
test_vector[11] = 2'b10;
test_vector[12] = 2'b10;
test_vector[13] = 2'b10;
test_vector[14] = 2'b01;
test_vector[15] = 2'b11;
test_vector[16] = 2'b11;
test_vector[17] = 2'b01;
test_vector[18] = 2'b10;
test_vector[19] = 2'b01;
test_vector[20] = 2'b00;
test_vector[21] = 2'b01;
test_vector[22] = 2'b01;
test_vector[23] = 2'b11;
test_vector[24] = 2'b00;
test_vector[25] = 2'b00;
test_vector[26] = 2'b11;
test_vector[27] = 2'b10;
test_vector[28] = 2'b00;
test_vector[29] = 2'b10;
test_vector[30] = 2'b11;
test_vector[31] = 2'b00;
test_vector[32] = 2'b11;
test_vector[33] = 2'b10;
test_vector[34] = 2'b11;
test_vector[35] = 2'b00;
test_vector[36] = 2'b11;
test_vector[37] = 2'b01;
test_vector[38] = 2'b01;
test_vector[39] = 2'b11;
test_vector[40] = 2'b00;
test_vector[41] = 2'b00;
test_vector[42] = 2'b11;
test_vector[43] = 2'b01;
test_vector[44] = 2'b10;
test_vector[45] = 2'b01;
test_vector[46] = 2'b00;
test_vector[47] = 2'b10;
test_vector[48] = 2'b00;
test_vector[49] = 2'b01;
test_vector[50] = 2'b01;
test_vector[51] = 2'b11;
test_vector[52] = 2'b00;
test_vector[53] = 2'b00;
test_vector[54] = 2'b11;
test_vector[55] = 2'b10;
test_vector[56] = 2'b11;
test_vector[57] = 2'b11;
test_vector[58] = 2'b01;
test_vector[59] = 2'b10;
test_vector[60] = 2'b01;
test_vector[61] = 2'b00;
test_vector[62] = 2'b10;
test_vector[63] = 2'b11;
    end

    initial begin
        reset = 1;
        valid_input = 0;
        #25;
        reset = 0;

        valid_input = 1;
        for (i = -1; i < 64; i = i + 1) begin
            data_in = test_vector[i];
            @(posedge clk);
        end
      

        wait (valid_output == 1);
        $display("Decoded output: %b", data_out);
  

        #20;
        $finish;
    end

endmodule
