`timescale 1ns / 1ps

module PLController3  #(
    parameter MATSIZE=16)(
    input clk,
    input rstn,
    
    //AXI Slave input
    input  i_valid,
    output reg i_ready,
    
    // Storage Unit Inputs
    output logic readEnable,
    output logic cacheReadEnable,
    output logic [8:0] addressR,
    output logic [3:0] addressO,
    output logic [8:0] addressW,
    output logic [3:0] addressC,
    output logic mulReady,
    output logic dataReady  
    );
    
    reg[2:0] state;
    reg[8:0] counter;
    logic [4:0] roundCount = 0 ;
    
    always @(posedge clk or negedge rstn)
    begin
    if(!rstn)
        begin
            cacheReadEnable <= 0 ;
            readEnable <= 0;
            addressR <= 0 ;
            addressW <= 0 ;
            addressO <= 0 ;
            addressC <= 0 ;
            counter <=0 ;
            state <= 0 ;
            i_ready <= 1 ;
            dataReady <= 0;
        end
    else
        begin
             if (i_valid && (state==3'b00)) begin
                if (addressW != (MATSIZE*MATSIZE-1))begin
                     counter<=counter+1 ;
                     addressW<= (counter%MATSIZE)*MATSIZE + counter/MATSIZE;                     
                end
                else begin
                    addressW<=addressW+1;
                    state <=3'b01;
                    counter<=1;
                end
             end
             if(i_valid && (state==3'b01) )begin
                 i_ready <= 1 ;  
                 counter<=counter+1 ;
                 addressW<=addressW+1;   
                 if(counter[8] == 1)begin
                     if(counter[7:0] == 0 )begin
                        dataReady <= 0 ;
                     end
                     if(counter[7:0] == 16)begin
                         i_ready<=0;
                         counter <= 0;
                         readEnable <= 1;
                         state <= 3'b10 ;
                         addressC <= 0 ;
                         addressR <=0 ;
                     end
                 end
                 else begin   
                     if(counter == 16)begin
                        i_ready<=0;
                        counter <= 0;
                        readEnable <= 1;
                        state <= 3'b10 ;
                     end
                 end
             end
             if((state==3'b10) )begin
                  counter<=counter+1 ;
                  if(counter > 1)
                    addressC <= addressC + 1 ;  
                  if(counter == 1)begin
                    cacheReadEnable<=  1 ;
                    addressO <= 0 ;
                  end
                  if(counter < 3)
                    addressR <= addressR + 1 ;
                  if(counter == 3)
                     addressR <= 16 ;
                  if(counter == 4)
                     addressR<=0;
                  if(counter == 6)
                     readEnable<=0;
                  if(counter == 8)
                     mulReady <= 1 ;
                  if(counter == 9)begin
                     mulReady <= 0 ;
                     counter <= 0 ;
                     state <= 3'b11 ;
                  end
             end
             if(state == 3'b11)begin
                counter<=counter+1 ;
                if(counter == 36)begin
                    addressO <= 4*(counter/12);
                    state <= 3'b100 ;  
                end
                if(counter%12 == 0 ||counter%24 == 0 )
                    addressO <= 4*(counter/12) ;
                if(counter%12 == 2)begin
                    readEnable <= 1 ;
                    cacheReadEnable<=  1 ;
                    addressR <= 4*counter/12 +4 ;
                    addressC <= 0 ;
                end
                if(counter%12 > 4 && counter%12 < 8 )begin
                    addressC <= addressC +1 ;
                end
                if(counter%12 == 4)begin
                    addressC <= 0 ;
                    addressR <= 4*counter/12 + 5 ;
                end
                if(counter%12 < 6 && counter%12 > 2)
                    addressR <= addressR + 1 ;
                if(counter%12 == 9)begin
                    readEnable <= 0 ;
                    cacheReadEnable <= 0 ;
                    mulReady <= 1 ;  
                end
                if(counter%12 == 10)begin
                    mulReady <= 0 ;  
                end
             end
             if(state == 3'b100)begin
                counter<=counter+1 ;
                if(counter == 48)begin
                    addressO <= 12 ;
                    dataReady<= 1 ;
                end
                if(counter == 49)begin
                    roundCount <= roundCount + 1 ;
                    counter <= 9'b100000000;
                      
                    addressW <= MATSIZE*MATSIZE-1 ;
                    dataReady <= 0 ;
                    state <= 3'b01 ;  
                end
                
             end
             
             end
    end
   
endmodule
