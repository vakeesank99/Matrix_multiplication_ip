`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2023 12:20:25 AM
// Design Name: 
// Module Name: PLOutputController
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


module AXIoutput#( 
    parameter BITWIDTH = 32,
    parameter MATSIZE =16 )(
  input clk,
  input rstn,
  input logic signed [MATSIZE-1:0][BITWIDTH-1:0] data_in,
  output logic signed [BITWIDTH-1:0] data_out,
  output reg valid,
  input data_ready,
  input o_ready
  //output reg  state,
  //output reg [7:0] counter 
);

  reg [7:0] counter; 
  reg  state;  
  // State definitions
  localparam IDLE = 1'b0;
  localparam WAITING = 1'b1 ;
  //parameter SEND_DATA = 2'b01;

  initial begin
        state <= IDLE;
      counter <= 0;
      valid <= 0;
      data_out <= 0;
  end
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state <= IDLE;
      counter <= 0;
      valid <= 0;
      data_out <= 0;
    end else begin
      case(state)
        IDLE: begin
          valid <= 0;
          if (data_ready) begin
            state <= WAITING;
            valid <= 1 ;
            counter <= 1 ;
            data_out <= data_in[counter];
          end
        end
//        WAITING: begin
//                    if(o_ready)begin
//                        state <= SEND_DATA ;
//                    end  
//                end 
        //default: state <= IDLE;
        
      endcase
      
      //if (state==SEND_DATA) begin
            //begin
                       if(o_ready && state==WAITING)begin
                          if (counter < MATSIZE) begin 
                            data_out <= data_in[counter];
                            counter <= counter + 1;
                            valid <=1;
                          end else begin
                            valid <= 0;
                            counter<=0;
                            state <= IDLE;
                          end
                       end
//                       else 
//                            state <= WAITING ;
                   //end
           // end
    end
  end

endmodule