module vitebri (
    input reset,
    input [1:0] data_in,
    output reg [61:0] data_out,
    output reg valid_output,
    input valid_input,
    input clk,
    output wire [9:0] coun,
    output wire [2:0] stt,
    output wire [1:0] humm,
    output wire [2:0] min,
    output wire path,
    output wire [15:0] PM0_debug,
    output wire [15:0] PM1_debug,
    output wire [15:0] PM2_debug,
    output wire [15:0] PM3_debug
  
);

   
 
     reg PathM [0:3][0:64]; 
     reg [1:0] hummingd [0:7]; 
    reg [15:0] PM [0:3][0:65];

      reg [2:0] state;
      reg [8:0] counter;
    integer i, j;
    reg [1:0] final_min;
    reg [1:0] min0 , min1 ; 
     
  reg [1:0] next_final_min;

 

    assign humm = hummingd[7];
    assign min = final_min;
    assign stt = state;
    assign coun = counter;
    assign path = PathM[3][30];
    assign PM0_debug = PM[0][(counter == 0) ? 0 : counter - 1];
    assign PM1_debug = PM[1][(counter == 0) ? 0 : counter - 1];
    assign PM2_debug = PM[2][(counter == 0) ? 0 : counter - 1];
    assign PM3_debug = PM[3][(counter == 0) ? 0 : counter - 1];



    always @(negedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            state <= 0;
            valid_output <= 0;

            for (i = 0; i < 4; i = i + 1) begin
                PM[i][0] <= 16'd0 ;
                for (j = 1; j < 34; j = j + 1) begin
                    PM[i][j] <= 16'hFFFF;
               end 
               end 
               end 
         else begin
           
        if (state==0 ) begin
                    if ( valid_input ) begin
                      hummingd[0] <=(data_in[0]  ^ 1'b0) +  (data_in[1]  ^ 1'b0 ); 
                     hummingd[1] <=(data_in[0]  ^ 1'b1 )+  (data_in[1]  ^ 1'b1) ;
                      hummingd[2] <=(data_in[0]  ^ 1'b1 )+  (data_in[1]  ^ 1'b1) ;
                      hummingd[3] <=(data_in[0]  ^ 1'b0 )+  (data_in[1]  ^ 1'b0 );
                        hummingd[4] <=(data_in[0]  ^ 1'b0) + ( data_in[1]  ^ 1'b1) ;
                        hummingd[5] <=(data_in[0]  ^ 1'b1 )+  (data_in[1]  ^ 1'b0 );
                         hummingd[6] <=(data_in[0]  ^ 1'b1)+ ( data_in[1]  ^ 1'b0 );
                        hummingd[7] <=(data_in[0]  ^ 1'b0)+  (data_in[1]  ^ 1'b1 );
                     state <= 1 ;  
                  end 
                 end   
                 end 
                    
               end                
       always @(negedge clk ) begin
               if (!reset) begin 
              if  (state == 1 )
                begin
               if (PM[0][counter] +hummingd[0]< PM[2][counter] + hummingd[1]) begin 
                        PM[0][counter+1] <= PM[0][counter] + hummingd[0];
                        PathM[0][counter] <=  1'b0 ; 
                    end else begin 
                     PM[0][counter+1] <= PM[2][counter] + hummingd[1];
                        PathM[0][counter] <=  1'b1 ; 
                        end 
                        
                      if (  PM[0][counter] +  hummingd[2]<  PM[2][counter] +  hummingd[3]) begin 
                        PM[1][counter+1] <= PM[0][counter] + hummingd[2];
                        PathM[1][counter] <=  1'b0 ; 
                    end else begin 
                     PM[1][counter+1] <= PM[2][counter] + hummingd[3];
                        PathM[1][counter] <=  1'b1 ; 
                        end 
                        
                       if (PM[1][counter]+hummingd[4]< PM[3][counter]+hummingd[5]) begin 
                        PM[2][counter+1] <= PM[1][counter] + hummingd[4];
                        PathM[2][counter] <=  1'b0 ; 
                    end else begin 
                     PM[2][counter+1] <= PM[3][counter] + hummingd[5];
                        PathM[2][counter] <=  1'b1 ; 
                        end 
                        
                       if ( PM[1][counter] + hummingd[6]<  PM[3][counter] +hummingd[7]) begin 
                        PM[3][counter+1] <= PM[1][counter] + hummingd[6];
                        PathM[3][counter] <=  1'b0 ; 
                    end else begin 
                     PM[3][counter+1] <= PM[3][counter] + hummingd[7];
                        PathM[3][counter] <=  1'b1 ; 
                        end 
                        
                       if (counter != 64) begin
                        counter <= counter +1 ; 
                       state <= 0 ; 
                   end   else begin 
                        state <= 2 ; 
                    end
           
                end
                end
                end

  
  always @(negedge clk ) begin
           
              if  (state == 2 )
                begin
                    min0 = (PM [0][counter+1] < PM [1][counter+1]) ? 0 : 1 ; 
                      min1= (PM [2][counter+1] < PM [3][counter+1]) ? 2 : 3 ;
                     final_min <=   min0 <= (PM [min0][counter+1] < PM [min1][counter+1]) ? min0 : min1 ;
                
                state <= 3 ; 
                end 
                end



  always @( posedge clk ) begin
               if (state == 3) begin
        case (final_min)
            2'b00: begin
              if (counter<62)begin
                data_out[counter] <= 1'b0;
                end 
                next_final_min = (PathM[0][counter] == 0) ? 2'b00 : 2'b10;
            end
            2'b01: begin
                 if (counter<62)begin
                  data_out[counter] <= 1'b1;
                  end
                next_final_min = (PathM[1][counter] == 0) ? 2'b00 : 2'b10;
            end
            2'b10: begin
                 if (counter<62)begin
                  data_out[counter] <= 1'b0;
                  end
                next_final_min = (PathM[2][counter] == 0) ? 2'b01 : 2'b11;
            end
            2'b11: begin
                  if (counter<62)begin 
                  data_out[counter] <= 1'b1;
                  end
                next_final_min = (PathM[3][counter] == 0) ? 2'b01 : 2'b11;
            end
        endcase


        if (counter==0) begin
            state <= 0;
            valid_output <= 1;
        end 
    end
    end
   always @(negedge clk  ) begin
               if (state == 3) begin 
                        final_min <= next_final_min;
                         counter<=counter-1 ; 
                    end 
                 end 
                      
    
endmodule
