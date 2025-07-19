`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: QAMMOD
// Description: 16-QAM Baseband Modulator
//////////////////////////////////////////////////////////////////////////////////

module QAMMOD (
    input  wire        clk,
    input  wire        reset,
    input  wire        data_valid,
    input  wire [3:0]  in_bits,
    output reg  signed [7:0] I_out,
    output reg  signed [7:0] Q_out,
    output reg         valid_out
);

// Symbol Mapper Function
function signed [7:0] map_2bit;
    input [1:0] bits;
    begin
        case (bits)
            2'b00: map_2bit = -3;
            2'b01: map_2bit = -1;
            2'b11: map_2bit =  1;
            2'b10: map_2bit =  3;
            default: map_2bit = 0;
        endcase
    end
endfunction

always @(posedge clk) begin
    if (reset) begin
        I_out      <= 0;
        Q_out      <= 0;
        valid_out  <= 0;
    end else if (data_valid) begin
        I_out      <= map_2bit(in_bits[3:2]);  // MSBs → I
        Q_out      <= map_2bit(in_bits[1:0]);  // LSBs → Q
        valid_out  <= 1;
    end else begin
        valid_out  <= 0;
    end
end

endmodule
