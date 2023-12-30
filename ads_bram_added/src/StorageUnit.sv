`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2023 07:15:36 PM
// Design Name: 
// Module Name: StorageUnit
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


module StorageUnit #(
    parameter BITWIDTH=32,
    parameter MATSIZE =16)(
      input wire cacheReadEnable,
      input wire writeEnableO,
      input wire readEnableO,
      input wire writeEnable,
      input wire readEnable,
      input wire [8:0] addressR,
      input wire [3:0] addressO,
      input wire [8:0] addressW,
      input wire [3:0] addressC,
      input wire clk,
      input logic signed [BITWIDTH-1:0] dataIn,
      output logic signed [MATSIZE-1:0][BITWIDTH-1:0] dataOutB0,
      output logic signed [MATSIZE-1:0][BITWIDTH-1:0] dataOutB1,
      output logic signed [MATSIZE-1:0][BITWIDTH-1:0] dataOutB2,
      output logic signed [MATSIZE-1:0][BITWIDTH-1:0] dataOutB3,
      output logic signed [MATSIZE-1:0][BITWIDTH-1:0] dataOutA,
      output logic signed [MATSIZE-1:0][BITWIDTH-1:0] outputCache,
      input logic signed [BITWIDTH-1:0] PEData_In0,
      input logic signed [BITWIDTH-1:0] PEData_In1,
      input logic signed [BITWIDTH-1:0] PEData_In2,
      input logic signed [BITWIDTH-1:0] PEData_In3
    );
   logic signed [MATSIZE*MATSIZE*2-1 : 0] dataOut;
   logic signed [4:0][MATSIZE-1:0][BITWIDTH-1:0] cacheData;
   Block_RAM_3 BRAM (
      .clka(clk),    // input wire clka
      .ena(writeEnable),      // input wire ena
      .wea(writeEnable),      // input wire [0 : 0] wea
      .addra(addressW),  // input wire [8 : 0] addra
      .dina(dataIn),    // input wire [31 : 0] dina
      .clkb(clk),    // input wire clkb
      .enb(readEnable),      // input wire enb
      .addrb(addressR),  // input wire [4 : 0] addrb
      .doutb(dataOut)  // output wire [511 : 0] doutb
    );

  
  always @(posedge clk) begin
      if(readEnable)
      begin
          cacheData[addressC] <=  dataOut;
      end
      if(cacheReadEnable) begin
          dataOutB0 <= cacheData[0];
          dataOutB1 <= cacheData[1];
          dataOutB2 <= cacheData[2];
          dataOutB3 <= cacheData[3];
          dataOutA <= cacheData[4];
      end
      outputCache[addressO] <= PEData_In0 ;
      outputCache[addressO + 1] <= PEData_In1;
      outputCache[addressO + 2] <= PEData_In2;
      outputCache[addressO + 3] <= PEData_In3;
  end
  
endmodule
