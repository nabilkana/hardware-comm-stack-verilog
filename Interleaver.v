`timescale 1ns / 1ps

module Interleaver (
    input  wire clk,
    input  wire in_bit,
    input  wire load_en,    
    output reg data_valid = 1'b0,
       
    output reg  [3:0] out_bits     // 4-bit interleaved output
);

    // 16 symbols, each 8 bits 
    reg [7:0] matrix [0:15];
    reg reading = 0;
    reg reading_next = 0; 
    reg [1:0] col; // 4 columns
    reg [2:0] bit_pos; // 8bits
    reg [6:0] cycle_count = 0; // switching between load and read 
    reg       load_phase = 1'b1  ; // 1 = load input phase, 0 = output read phase 
always @(posedge clk) begin
    if (load_phase) begin
        reading <= 0;
        reading_next <= 0;
        data_valid <= 0;

        if (load_en) begin
            matrix[cycle_count[6:3]][cycle_count[2:0]] <= in_bit;
            cycle_count <= cycle_count + 1;
            
            if (cycle_count == 127) begin
                cycle_count <= 0;
                load_phase <= 0;
                reading_next <= 1;
            end
        end
    end else begin
        col     <= cycle_count[6:3];                
        bit_pos <= 3'd7 - cycle_count[2:0];

        out_bits[0] <= matrix[0 + 4*col][bit_pos];
        out_bits[1] <= matrix[1 + 4*col][bit_pos];
        out_bits[2] <= matrix[2 + 4*col][bit_pos];
        out_bits[3] <= matrix[3 + 4*col][bit_pos];
        
        data_valid <= reading;
        reading <= reading_next;
        cycle_count <= cycle_count + 1;

        if (cycle_count == 33) begin
            cycle_count <= 0;
            load_phase  <= 1'b1;
            reading <= 0;
            reading_next <= 0;
            data_valid <= 0;
        end
    end
end


endmodule
