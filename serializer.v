module serializer (
    input clk,
    input reset,
    input valid,     // input valid, could be high for multiple clocks
    input v1,
    input v2,
    output reg out_bit,
    output reg valid_out
);

    reg [1:0] buffer;
    reg bit_index;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            out_bit <= 0;
            valid_out <= 0;
            buffer <= 2'b00;
            bit_index <= 0;
        end else begin
            valid_out <= valid;  // output valid follows input valid exactly

            if (valid && bit_index == 0) begin
                // Load inputs when valid is high and at start of serialization
                buffer <= {v1, v2};
                out_bit <= v1;
                bit_index <= 1;
            end else if (valid && bit_index == 1) begin
                // Output second bit while valid is still high
                out_bit <= buffer[0];
                bit_index <= 0;
            end else begin
                // valid low or no valid input, output zero
                out_bit <= 0;
                bit_index <= 0;
            end
        end
    end

endmodule
