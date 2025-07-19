module serial_to_pair (
    input clk,
    input reset,
    input deint_out,
    input deint_out_valid,
    output reg [1:0] vitebri_data_in,
    output reg vitebri_valid_in
);

    reg [0:0] bit0;
    reg collected;

    // counter to track valid pulse duration
    reg [1:0] valid_counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            vitebri_valid_in <= 0;
            vitebri_data_in <= 2'b00;
            bit0 <= 0;
            collected <= 0;
            valid_counter <= 0;
        end else begin
            // Extended valid signal
            if (valid_counter > 0) begin
                vitebri_valid_in <= 1;
                valid_counter <= valid_counter - 1;
            end else begin
                vitebri_valid_in <= 0;
            end

            if (deint_out_valid) begin
                if (!collected) begin
                    bit0 <= deint_out;
                    collected <= 1;
                end else begin
                    vitebri_data_in <= {bit0, deint_out};
                    valid_counter <= 3; // Now lasts 3 cycles
                    collected <= 0;
                end
            end

            // Optional: Flush final bit if needed
            if (collected && !deint_out_valid) begin
                vitebri_data_in <= {bit0, 1'b0};  // pad with 0
                valid_counter <= 3;
                collected <= 0;
            end
        end
    end
endmodule
