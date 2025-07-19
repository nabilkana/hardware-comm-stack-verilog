module LFSR (
    input clk,
    input reset,
    input load,
    input [6:0] seed,
    output wire q,
    output reg valid_out  
);

    wire [6:0] inter;
    wire f;

    // 128-bit output counter
    reg [7:0] bit_count = 0;

    shiftr #(7) shift_reg (
        .clk(clk),
        .load(load),
        .seed(seed),
        .reset(reset),
        .data(f),
        .q(inter)
    );

    assign f = inter[6] ^ inter[0];  // Polynomial: x⁷ + x¹ + 1
    assign q = inter[6];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            valid_out <= 0;
            bit_count <= 0;
        end else if (load) begin
            valid_out <= 1;
            bit_count <= 0;
        end else begin
            if (bit_count == 61) begin
                valid_out <= 0;  
            end else begin 
             bit_count <= bit_count + 1;
             valid_out <= 1 ; 
             end 
        end
    end

endmodule
