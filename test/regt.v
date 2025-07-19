`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2025 01:37:09 PM
// Design Name: 
// Module Name: regt
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


module regt(

    );
   reg clk;
    reg data;
    reg load ;
    reg reset ;
    wire  v1 ,v2 ;
    
    convenc  uut (
    .v1(v1),
    .v2(v2), 
    .data(data),
    .clk(clk),
    .reset(reset), 
    .load(load),
    .seed(3'b101)
    );
      
    
    always #5 clk = ~clk;

    initial begin
        $dumpfile("convenc.vcd");
        $dumpvars(0, regt);
       load = 0 ; 
        reset = 0 ;
        clk = 0;
        data = 0;

        #3   data = 1;
        #10  data = 0;
        #10  data = 1;
        #10 data = 0 ; 
        #10 data = 0 ; 
        #10 data = 0 ; 
         #10 data = 1 ; 
        #10 data = 1 ; 
        #10 data = 1 ; 
        #10 data = 0 ;
        #100 $finish;
    end
endmodule
