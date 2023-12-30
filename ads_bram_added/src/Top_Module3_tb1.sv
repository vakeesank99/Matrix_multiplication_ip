`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2023 01:14:07 PM
// Design Name: 
// Module Name: Top_Module3_tb1
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/24/2023 01:11:05 PM
// Design Name: 
// Module Name: Top_Module3_tb1
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


`timescale 1ns / 1ps

module Top_Module3_tb1();

 // Parameters
  parameter CLK_PERIOD = 10; // Clock period in nanoseconds

  // Signals
  reg Clk;
  reg rstn;
  reg [31:0] i_data;
  reg i_valid;
  wire i_ready;
   reg [511:0][31:0] MatAB;
   reg [255:0][31:0] MatAns;
  reg o_valid;
  reg o_ready;
  reg [31:0] o_data;
  //wire signed [15:0][31:0] outBus;
 // reg mul_ready;
  //reg [3:0] flag;
  int count;
  int count2 ;
  logic signed [511 : 0] dataOut;
  logic [2:0] state;
  logic signed [31:0] PEData_In0;
  logic signed [31:0] PEData_In1;
  logic signed [31:0] PEData_In2;
  logic signed [31:0] PEData_In3;
  logic signed [15:0][31:0] dataOutB0;
  logic signed [15:0][31:0] dataOutB1;
  logic signed [15:0][31:0] dataOutB2;
  logic signed [15:0][31:0] dataOutB3;
  logic signed [15:0][31:0] dataOutA;
  logic dataReady;
  logic [3:0] addressC;
  logic [8:0] addressR;
  logic signed [15:0][31:0] outputCache;
  reg[8:0] counter;
  logic signed [4:0][15:0][31:0] cacheData ;
  logic readEnable;
  logic [3:0] addressO ;
  // Instantiate the DUT
  TopModule3 uut (
    .rstn(rstn),
    .i_data(i_data),
    .i_valid(i_valid),
    .i_ready(i_ready),
    .o_valid(o_valid),
    .o_ready(o_ready),
    .o_data(o_data),
    .Clk(Clk)
    //.outBus(outBus),
    //.mul_ready(mul_ready),
    //.flag(flag)
    
  );

  // Clock generation
  always begin
    #(CLK_PERIOD/2) Clk = ~Clk;
  end
  
  //AXI In
  always @(posedge Clk) begin
      if (i_ready && i_valid) begin
      i_data = MatAB[count];
      count=count+1;
      end
  end
  
    //AXI out
  always @(posedge Clk) begin
      if (o_ready && o_valid) begin
      MatAns[count2] = o_data;
      count2=count2+1;
      end
  end
  // Initial block
  initial begin
    // Initialize signals
    for (int i = 0; i < 256; i = i + 1) begin
        MatAB[i] = i;
        MatAB[i+256] = i;
    end
    Clk = 0;
   rstn = 1;
    i_data = 1;
    i_valid = 0;
    o_ready = 1;
    count=0;
    count2=0;
    #10 rstn = 0;
    #10 rstn = 1;
    i_valid = 1;
    #2735 
    i_valid = 0;
    #4000
    i_valid = 1;
    #16600



           $display("Matrix Display:");
      for (int row = 0; row < 16; row = row + 1) begin
        for (int col = 0; col < 16; col = col + 1) begin
          $write("%8d ", MatAns[row*16 + col]);
        end
        $display(""); // Newline after each row
      end
      $display(""); // Extra newline for better formatting

    // Finish the simulation
    $finish;
    

    end
  


endmodule

