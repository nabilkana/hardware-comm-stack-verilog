
module convenc(
    input data,
    input clk,
    input reset,
    input load,
    input [2:0] seed,
    input valid_in,
    output wire v1,
    output wire v2,
    output reg valid_out
);
    reg datain_controlled;
    wire [2:0] q;
    reg [7:0] valid_counter; 
    reg [7:0] flush_count;

    // Shift register instance
    shiftr #(3) shift_reg (
        .clk(clk),
        .load(load),
        .seed(seed),
        .reset(reset),
        .data(datain_controlled),
        .q(q)
    );

    assign v1 = q[2] ^ q[1] ^ q[0];
    assign v2 = q[2] ^ q[0];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            valid_counter <= 0;
            flush_count <= 0;
            valid_out <= 0;
        end else begin
            if (valid_in  ) begin
               
                
                   valid_out<=1 ; 
                  
             
                valid_counter <= valid_counter + 1;
                flush_count <= 0;  
            end else if (valid_counter == 0) begin
                valid_out <= 0;
             end else if (valid_counter != 0 && flush_count != 2) begin
                 
                flush_count <= flush_count + 1 ;
              
          end else   begin
                    valid_out <= 0;
                    valid_counter <= 0;  
                    flush_count <= 0;
                end
             end
             
        end
    
always @(*) begin
    if (valid_in)
        datain_controlled = data;
    else
        datain_controlled = 1'b0;  
end
endmodule
