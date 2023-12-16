`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/23/2023 01:07:00 PM
// Design Name: 
// Module Name: PLcontroller
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


module PLcontroller #(
    parameter MATSIZE=16)(

input clk,
input rstn,

//AXI Slave input

input  i_valid,
output reg i_ready,

//AXI Master output

//output reg [5:0] o_valid,
//input o_ready,

//Shift cache buffer address
output reg [8:0] shiftAdr,
//output reg WriteEnable
output reg mul_ready,
input [3:0] flag,
output  reg AXI_out,
output reg o_intr
//output reg [7:0] flag_count
    );
    
 reg[1:0] state;
 reg [8:0] counter;
 reg valid_output;
 reg [7:0] flag_count =0;

 initial 
     begin
    shiftAdr <=0;
    i_ready <=0;
    o_intr <=0;
    counter <=0;
    mul_ready<=0;
    AXI_out<=0;
    valid_output<=0;
    state <=2'b00;
    flag_count<=0;
    end
 always @(posedge clk or negedge rstn)
 begin
 if(!rstn)
    begin
    shiftAdr <=0;
    i_ready <=0;
    counter <=0;
    mul_ready<=0;
    AXI_out<=0;
    valid_output<=0;
    state <=2'b00;
    flag_count<=0;
    end
  else
  begin
      if (i_valid && (state==2'b00)) begin //Write transpose of matrix B to cache buffer
          if (shiftAdr != (255))begin
            counter<=counter+1;
            //shiftAdr <= shiftAdr/(matSize*(matSize-1))  +(matSize +shiftAdr)%(matSize*(matSize-1));
            //shiftAdr <= (counter*matSize + shiftAdr/(matSize*(matSize-1)))%256;
            shiftAdr<= (counter%MATSIZE)*MATSIZE + counter/MATSIZE;
            i_ready<=1;
            
          end
          else begin
            shiftAdr<=shiftAdr+1;
            state <=2'b01;
            counter<=1;
            end
      end
      if(i_valid && (state==2'b01) )begin
            shiftAdr<=shiftAdr+1;
            //i_ready<=1;
            if (shiftAdr==(MATSIZE*MATSIZE + MATSIZE -1 )) begin
                shiftAdr<=0;
                counter[8]<=1;
               // mul_ready<=1;
                state<=2'b10;
                i_ready<=0;
                o_intr<=0;
                end
            end
      if(state==2'b10)begin
        //shiftAdr<=0;//shiftAdr+matSize;
       
        counter <= counter+1;
        if (counter[7:0]%11==(0)) begin
                shiftAdr<=shiftAdr+MATSIZE*4;
                counter[8]<=1;
                mul_ready<=1;
                end
        if(counter[8])begin
            counter[8]<=0;
            mul_ready<=1;
            end
        else
            begin
            mul_ready<=0;
            end
        if (counter[7:0]%44==(0)) begin
                state<=2'b01;
                mul_ready<=0;
                shiftAdr<=MATSIZE*MATSIZE;
                i_ready<=1;
                o_intr<=1; 
                end
        end
        
        if (flag_count!=0 && flag_count%4==0 && valid_output)begin
            AXI_out<=1;
            valid_output<=0;
            end
        else begin
            AXI_out<=0;
            end      
      
  
  
  end
  end
//ila_0 your_instance_name (
//	.clk(clk), // input wire clk


//	.probe0(flag) // input wire [3:0] probe0
//);
  always @(posedge flag) begin
  if (flag==4'b1111 ) begin
    flag_count <= flag_count+1;
    valid_output<=1;
    end
  if (flag_count == (MATSIZE*MATSIZE/4))begin
    flag_count <=0;
    state <= 0;
    //i_ready <=0;
    counter <=0;
    end
//  if ( flag_count!=0 && flag_count%4==0)begin
//    valid_output<=1;
//    end
//  else begin
//    AXI_out<=0;
//    end
  end
 

endmodule