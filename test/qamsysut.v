`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: qamsysut
// Description: Drives the TopMod system (LFSR → Encoder → Serializer → Interleaver → QAM)
// Dumps waveforms to VCD and logs I/Q data to a text file.
//////////////////////////////////////////////////////////////////////////////////

module qamsysut;

    reg clk = 0;
    reg reset = 1;
    reg resetlfsr = 1;
    reg lfsr_load = 0;
    reg [6:0] lfsr_seed = 7'b1010101;

    wire signed [7:0] I_out;
    wire signed [7:0] Q_out;
    wire valid_out;
   wire lfsr_valid ; 
    wire lfsr_bit;
    wire encoder_v1, encoder_v2;
    wire serializer_out_bit, serializer_valid;
    wire [3:0] interleaver_out;
    wire interleaver_valid;
  wire clk_slow ; 
    integer outfile;
    integer outfile2 ; 

    TopMod uut (
        .clk(clk),
        .reset(reset),
        .resetlfsr(resetlfsr),
        .lfsr_seed(lfsr_seed),
        .lfsr_load(lfsr_load),
        .I_out(I_out),
        .Q_out(Q_out),
        .valid_out(valid_out),
        .lfsr_bit(lfsr_bit),
        .encoder_v1(encoder_v1),
        .encoder_v2(encoder_v2),
        .serializer_out_bit(serializer_out_bit),
        .serializer_valid(serializer_valid),
        .interleaver_out(interleaver_out),
        .interleaver_valid(interleaver_valid),
        .lfsr_valid(lfsr_valid),
        .clk_slow_out(clk_slow)
    );

    always #5 clk = ~clk;
      integer i;
      reg [6:0] seed_values [0:15];
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, qamsysut);

        outfile = $fopen("qamt16sym_output.txt", "w");
        outfile2 = $fopen("OriginalBitst.txt", "w");

       seed_values[0] = 7'b1010101;
        seed_values[1] = 7'b0101010;
        seed_values[2] = 7'b1110001;
        seed_values[3] = 7'b0001110;
        seed_values[4] = 7'b1001101;
        seed_values[5] = 7'b0110010;
        seed_values[6] = 7'b1100110;
        seed_values[7] = 7'b0011001;
        seed_values[8] = 7'b1000001;
        seed_values[9] = 7'b0101010;
        seed_values[10] = 7'b1011101;
        seed_values[11] = 7'b1101110;
        seed_values[12] = 7'b1000101;
        seed_values[13] = 7'b1100010;
        seed_values[14] = 7'b1010110;
        seed_values[15] = 7'b0011111;

         for (i = 0; i < 16; i = i + 1) begin
        reset      = 1;
        resetlfsr  = 1;
        lfsr_seed  = seed_values[i];

        #10;
        reset      = 0;
        #5;
         resetlfsr  = 0;
         lfsr_load  = 1;
         #5;
          lfsr_load  = 0;
        resetlfsr = 0;

       
        #2500;
         
    end
   #20000;
    reset = 1;
    resetlfsr = 1;
$fflush(outfile);
         $fclose(outfile);
         $fflush(outfile2);
$fclose(outfile2); 
   
    
         end
         
    
        
    

    always @(posedge clk_slow) begin
     if (lfsr_valid) begin
            $fwrite(outfile2,"%d\n", lfsr_bit);
        end
      end
      always @(posedge clk) begin
        if (valid_out) begin
            $fwrite(outfile, "%0t, I = %d, Q = %d\n", $time, I_out, Q_out);
        end
        
    end

endmodule
