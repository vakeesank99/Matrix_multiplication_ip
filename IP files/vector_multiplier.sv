`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2023 12:51:23 PM
// Design Name: 
// Module Name: vector_multiplier
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

module vector_multiplier #(
    parameter BITWIDTH =32,
    parameter MATSIZE =16
  )(  
    input  logic clk, cen,
    input valid,
    input  logic signed    [MATSIZE-1:0][BITWIDTH-1:0] k,
    input  logic signed    [MATSIZE-1:0][BITWIDTH-1:0] x,
    output logic signed [MATSIZE-1:0][BITWIDTH-1:0] mul_vector ,
    output logic Flag, 
    output logic signed        [BITWIDTH-1:0] y
  );

  // Padding
 logic signed [MATSIZE/2-1:0][BITWIDTH-1:0] vec8_1; 
  logic signed [MATSIZE/2-1:0][BITWIDTH-1:0] vec8_2; 
  
  reg [BITWIDTH-1:0] sum1,sum2;
  reg [3:0] counter;
  
  genvar  c;
  
    for (c=0; c<16; c=c+1)
      always @(posedge clk) begin
 
        if (cen) mul_vector[c] <= $signed(k[c]) * $signed(x[c]);
     end
    
    
    
    always @(posedge clk) begin
        if (valid) begin
            sum1 <= 0;
            sum2 <= 0;
            Flag <= 0;
            counter <= 0;
        end
    end

        

  
  assign vec8_1 = mul_vector[MATSIZE/2-1:0];
  assign vec8_2 = mul_vector[MATSIZE-1:MATSIZE/2];  
   
   
   
  always @(posedge clk && ~Flag ) begin
    if (~cen ) begin
      sum1 <= 0;
      sum2 <= 0;
      Flag <= 0;
      counter <= 0;
    end 
    else begin
      if (counter < 8) begin
 
        sum1 <= sum1 + vec8_1[counter[2:0]];
        sum2 <= sum2 + vec8_2[counter[2:0]];
        
        counter <= counter + 1;
        
      end
      
      if (counter==8) begin
        y <= sum2+sum1;
        Flag <= 1;
    end   
  end
end
     
     
     
   //assign Flag = counter[3];
   
endmodule