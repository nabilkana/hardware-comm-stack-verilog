`timescale 1ns / 1ps

module topmod2_tb();

  reg clk = 0;
  reg reset = 1;
  reg [3:0] file_in_bits;
  reg data_ready;
  integer infile;
  reg [8*5:1] line;  
  integer r;
  integer count;
  integer lines;
  integer i ; 

  wire [61:0] decoded_data;
  wire decoded_valid;
  wire deint_out;
  wire deint_out_valid;
  wire [1:0] vitebri_data_in;
  wire vitebri_valid_in;
  wire [2:0] vitebri_state;
  wire [8:0] vitebri_counter;
  wire [15:0] PM0_debug;
  wire [15:0] PM1_debug;
integer outfile ; 

reg prev_decoded_valid ;



integer i ; 
  TopMod2 dut (
    .clk(clk),
    .reset(reset),
    .file_in_bits(file_in_bits),
    .data_ready(data_ready),
    .decoded_data(decoded_data),
    .decoded_valid(decoded_valid),
    .deint_out(deint_out),
    .deint_out_valid(deint_out_valid),
    .vitebri_data_in(vitebri_data_in),
    .vitebri_valid_in(vitebri_valid_in),
    .vitebri_state(vitebri_state),
    .vitebri_counter(vitebri_counter),
    .PM0_debug(PM0_debug),
    .PM1_debug(PM1_debug)
  );

  always #5 clk = ~clk;

  initial begin
    reset = 1;
    data_ready = 0;
    file_in_bits = 0;
    count = 0;
    lines = 0;

    #10;
    reset = 0;
    @(posedge clk);
 outfile = $fopen("decoded_outputburst20db.txt", "w");  
    if (outfile == 0) begin
      $display("Failed to open file!");
      $stop;
    end
    infile = $fopen("demodulated_burst_bits20db.txt", "r");
    if (infile == 0) begin
      $display("ERROR: Failed to open input file!");
      $stop;
    end

    while (lines < 512) begin
      count = 0;

      while (count < 32) begin
        r = $fgets(line, infile);
        if (r == 0) begin
          $display("ERROR: Reached EOF before 256 lines.");
          
          
        end

        file_in_bits[3] = (line[40 -: 8] == "1") ? 1'b1 : 1'b0;
        file_in_bits[2] = (line[32 -: 8] == "1") ? 1'b1 : 1'b0;
        file_in_bits[1] = (line[24 -: 8] == "1") ? 1'b1 : 1'b0;
        file_in_bits[0] = (line[16 -: 8] == "1") ? 1'b1 : 1'b0;

        data_ready = 1;
        @(posedge clk);
        data_ready = 0;
        @(posedge clk);

        count  = count + 1;
        lines  = lines + 1;
      end

      $display("Fed %0d lines. Waiting and resetting DUT...", lines);
      #2000;

  
         reset = 1;
    data_ready = 0;
    file_in_bits = 0;
    count = 0;
   

    #10;
    reset = 0;
    @(posedge clk);
    end
  $fclose(outfile);

    $fclose(infile);
    $display("Finished feeding 256 lines.");
    #1000000;
    $stop;
  end
always @(posedge clk) begin
  if (decoded_valid && !prev_decoded_valid) begin
    $display("DETECTED decoded_valid rising edge at time %0t", $time);
    for (i = 0; i <= 61; i = i + 1) begin

      $fwrite(outfile, "%b\n", decoded_data[i]);
    end
  end
  prev_decoded_valid <= decoded_valid;  // update at every cycle
end
endmodule
