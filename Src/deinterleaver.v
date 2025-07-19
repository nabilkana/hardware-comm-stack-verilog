`timescale 1ns / 1ps

module deinterleaver(
    input  wire clk,
    input wire reset ,
    input  wire [3:0] in_bits,
    input  wire data_ready,
    output reg out_ready ,
    output reg  data_out
);

    reg [7:0] matrix [0:15];

    // State machine
    reg read = 0;

    // Write phase counters
    reg [6:0] cycle_count = 7'd31;  // for 32 input chunks (4 bits each)

    // Read phase counters
    reg [3:0] row = 0;
    reg [2:0] bit_pos_r = 0;

    // Write-time computed values
    reg [1:0] col_w;
    reg [2:0] bit_pos_w;
always @(negedge clk or posedge reset) begin
   if (reset) begin
      out_ready <= 0 ; 
      end else begin
        if (!read && data_ready) begin
            // Write phase
            col_w     = cycle_count[4:3];           
            bit_pos_w = cycle_count[2:0];    

            matrix[12-4*col_w][bit_pos_w] <= in_bits[0];
            matrix[13- 4*col_w][bit_pos_w] <= in_bits[1];
            matrix[14-4*col_w][bit_pos_w] <= in_bits[2];
            matrix[15- 4*col_w][bit_pos_w] <= in_bits[3];

            if (cycle_count == 7'd0) begin
                read <= 1;
                cycle_count <= 7'd31;
            end else begin
                cycle_count <= cycle_count -1;
            end
        end

        else if (read) begin
    data_out <= matrix[row][bit_pos_r];
   out_ready <=1 ; 
    if (bit_pos_r == 7) begin
        bit_pos_r <= 0;
        if (row == 15) begin
            row <= 0;
            read <= 0;
            cycle_count <= 7'd31;
            out_ready <=0 ;   
        end else begin
            row <= row + 1;
        end
      end else begin
        bit_pos_r <= bit_pos_r + 1;
      end
     end
    end
end
endmodule
