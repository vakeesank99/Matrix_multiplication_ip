`timescale 1ns / 1ps



module TopModule3#(
    parameter BITWIDTH=32,
    parameter MATSIZE =16)(
    input logic Clk,
    input rstn,
    //AXI Slave input
    input [BITWIDTH-1:0] i_data,
    input  i_valid,
    output  i_ready,
    //AXI Master output
    output o_valid,
    input o_ready,
    output reg [BITWIDTH-1:0] o_data,
    output o_intr
 
    );
  
  wire logic signed [BITWIDTH-1:0] PEData_In0;
  wire logic signed [BITWIDTH-1:0] PEData_In1;
  wire logic signed [BITWIDTH-1:0] PEData_In2;
  wire logic signed [BITWIDTH-1:0] PEData_In3;
  
  wire logic signed [MATSIZE-1:0][BITWIDTH-1:0] dataOutB0;
  wire logic signed [MATSIZE-1:0][BITWIDTH-1:0] dataOutB1;
  wire logic signed [MATSIZE-1:0][BITWIDTH-1:0] dataOutB2;
  wire logic signed [MATSIZE-1:0][BITWIDTH-1:0] dataOutB3;
  wire logic signed [MATSIZE-1:0][BITWIDTH-1:0] dataOutA;
  logic signed [MATSIZE-1:0][BITWIDTH-1:0] outputCache;
  reg[8:0] counter;
  wire dataReady;
  wire mulReady;
  wire   [3:0] flag;
  wire AXI_out;
  wire logic writeEnableO;
  wire logic cacheReadEnable;
  wire logic readEnableO;
  wire logic readEnable;
  wire logic [8:0] addressR;
  wire logic [3:0] addressO;
  wire logic [8:0] addressW;
  wire logic [3:0] addressC;
    assign o_intr = 1;
  StorageUnit  #(
    .BITWIDTH(BITWIDTH),
    .MATSIZE(MATSIZE))
    StorageUnit(
      .cacheReadEnable(cacheReadEnable),
      .writeEnable(i_ready),
      .readEnable(readEnable),
      .addressR(addressR),
      .addressO(addressO),
      .addressW(addressW),
      .addressC(addressC),
      .clk(Clk),
      .dataIn(i_data),
      .PEData_In0(PEData_In0),
      .PEData_In1(PEData_In1),
      .PEData_In2(PEData_In2),
      .PEData_In3(PEData_In3),
      .dataOutB0(dataOutB0),
      .dataOutB1(dataOutB1),
      .dataOutB2(dataOutB2),
      .dataOutB3(dataOutB3),
      .dataOutA(dataOutA),
      .outputCache(outputCache)
    );
  PLController3 #(
  .MATSIZE(MATSIZE))
  PLController(
    .clk(Clk),
    .rstn(rstn),
    .i_valid(i_valid),
    .i_ready(i_ready),
    
    // Storage Unit Inputs
    .readEnable(readEnable),
    .cacheReadEnable(cacheReadEnable),
    .addressR(addressR),
    .addressO(addressO),
    .addressW(addressW),
    .addressC(addressC),
    .mulReady(mulReady),
    .dataReady(dataReady)
  );
  vector_multiplier #(
     .BITWIDTH(BITWIDTH),
     .MATSIZE(MATSIZE)) 
     PE0 (
    .clk(Clk),
    .cen(1),
    .valid(mul_ready),
    .k(dataOutA),
    .x(dataOutB0),
    .Flag(flag[0]),
    .y(PEData_In0)
  );
  
  vector_multiplier #( 
     .BITWIDTH(BITWIDTH),
     .MATSIZE(MATSIZE)) 
     PE1 (
    .clk(Clk),
    .cen(1),
    .valid(mul_ready),
    .k(dataOutA),
    .x(dataOutB1),
    .Flag(flag[1]),
    .y(PEData_In1)
  );
  vector_multiplier #( 
     .BITWIDTH(BITWIDTH),
      .MATSIZE(MATSIZE)) 
     PE2 (
    .clk(Clk),
    .cen(1),
    .valid(mul_ready),
    .k(dataOutA),
    .x(dataOutB2),
    .Flag(flag[2]),
    .y(PEData_In2)
  );
  vector_multiplier #( 
    .BITWIDTH(BITWIDTH),
     .MATSIZE(MATSIZE)) 
     PE3 (
    .clk(Clk),
    .cen(1),
    .valid(mul_ready),
    .k(dataOutA),
    .x(dataOutB3),
    .Flag(flag[3]),
    .y(PEData_In3)
  );
 AXIoutput #(
    .BITWIDTH(BITWIDTH),
    .MATSIZE(MATSIZE)) 
    AXIout (
    .clk(Clk),
    .rstn(rstn),
    .data_in(outputCache),
    .data_out(o_data),
    .valid(o_valid),
    .data_ready(dataReady),
    .o_ready(o_ready)
 );
 
endmodule
