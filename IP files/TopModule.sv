`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2023 05:06:44 PM
// Design Name: 
// Module Name: TopModule
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


module TopModule #(
    parameter BITWIDTH=32,
    parameter MATSIZE =16)(
    //input logic signed [15:0][31:0] inBus,
    //input logic signed [5:0]command,
    
    input rstn,
    //AXI Slave input
    input[BITWIDTH-1:0] i_data,
    input  i_valid,
    output reg i_ready,
    
    //AXI Master output
    output o_valid,
    input o_ready,
    output reg [BITWIDTH-1:0] o_data,
    input logic Clk,
    output reg o_intr
    //output logic signed [15:0][31:0] outBus
    //output mul_ready,
    //output [3:0] flag
    //output reg [4:0] flag_count
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
  wire [8:0] shiftAdr;
  logic signed [MATSIZE-1:0][BITWIDTH-1:0] outBus;
  wire mul_ready;
  wire [3:0] flag;
  wire AXI_out;
  
    CacheBuffer  #(
    .BITWIDTH(BITWIDTH),
    .MATSIZE(MATSIZE))
    CacheUnit(
    .WriteEnable(i_ready),
    .Address(shiftAdr),
    .Clk(Clk),
    .dataIn(i_data),
    .PEData_In0(PEData_In0),
    .PEData_In1(PEData_In1),
    .PEData_In2(PEData_In2),
    .PEData_In3(PEData_In3),
    .dataOutA(dataOutA),
    .dataOut(outBus),
    .dataOutB0(dataOutB0),
    .dataOutB1(dataOutB1),
    .dataOutB2(dataOutB2),
    .dataOutB3(dataOutB3)
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
  
  
    // Instantiate PLcontroller module
  PLcontroller #(
  .MATSIZE(MATSIZE))
  contoller (
    .clk(Clk),
    .rstn(rstn),
    .i_valid(i_valid),
    .i_ready(i_ready),
    .shiftAdr(shiftAdr),
    .mul_ready(mul_ready),
    .flag(flag),
    .AXI_out(AXI_out),
    .o_intr(o_intr)
    //.flag_count(flag_count)
  );
 
 AXIoutput #(
    .BITWIDTH(BITWIDTH),
    .MATSIZE(MATSIZE)) 
    AXIout (
    .clk(Clk),
    .rstn(rstn),
    .data_in(outBus),
    .data_out(o_data),
    .valid(o_valid),
    .data_ready(AXI_out),
    .o_ready(o_ready)
 );
 
endmodule
