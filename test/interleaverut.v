`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/11/2025 12:31:59 PM
// Design Name: 
// Module Name: interleaverut
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module interleaverut(
    );
    reg clk ;
    wire data_valid;      
reg in_bit ;
reg load_en;

wire [3:0] out_bits ; 
Interleaver uut (
        .clk(clk),
        .in_bit(in_bit),
        .load_en(load_en),
        .out_bits(out_bits),
            .data_valid(data_valid)  
    );
    reg [127:0] test_data = 128'hA5A5_5A5A_F0F0_0F0F_1234_ABCD_5678_EEEE;
    integer i = 0;



always #5 clk = ~clk; // 10ns period
        

    initial begin
        $dumpfile("Interleaver.vcd");
        $dumpvars(0, interleaverut);
       #1 clk =0 ;
        load_en = 0;
            for (i = 0; i < 128; i = i + 1) begin
            @(negedge clk);
                    load_en = 1;
            in_bit = test_data[127-i];  // Ensures it's stable before next posedge
        end
        #7500 $finish;
    end
endmodule
