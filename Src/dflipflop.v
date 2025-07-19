`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2025 01:08:01 PM
// Design Name: 
// Module Name: dflipflop
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


module dflipflop
# (parameter n=3)
(
input  clk , 
input  reset ,
input  [n-1 : 0] d ,  
output reg [n-1 : 0 ] q 


    );
 always @ (posedge clk ) begin 
  if (reset)
        q <= 0 ;
  else 
       q<= d ; 
   end 
 
 
endmodule
