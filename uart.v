`define STATE_IDLE      4'h0
`define STATE_START_BIT 4'h1
`define STATE_BIT_0     4'h2
`define STATE_BIT_1     4'h3
`define STATE_BIT_2     4'h4
`define STATE_BIT_3     4'h5
`define STATE_BIT_4     4'h6
`define STATE_BIT_5     4'h7
`define STATE_BIT_6     4'h8
`define STATE_BIT_7     4'h9
`define STATE_STOP_BIT  4'ha
`define STATE_STOPPED   4'hb

module uart(
            input       clk,
            input       reset,
            input [7:0] data,
            input       dataReady,
            output reg  busy,
            output reg  tx);

   parameter CLK_FREQ = 50000000;
   parameter BAUD = 9600;
   parameter BAUD_GEN_ACC_WIDTH = 16;
   parameter BAUD_GEN_INC = ((BAUD << (BAUD_GEN_ACC_WIDTH - 4)) + (CLK_FREQ >> 5)) / (CLK_FREQ >> 4);

   reg [BAUD_GEN_ACC_WIDTH:0] baudGenAcc;
   always @(posedge clk or posedge reset)
     if (reset)
       baudGenAcc <= 0;
     else
       baudGenAcc <= baudGenAcc[BAUD_GEN_ACC_WIDTH - 1 : 0] + BAUD_GEN_INC;
   wire baudClk = baudGenAcc[BAUD_GEN_ACC_WIDTH];

   reg [3:0] state;
   reg [7:0] dataBuf;

   always @(posedge clk or posedge reset)
     if (reset) begin
        state <= `STATE_IDLE;
     end else
       case (state)
         `STATE_IDLE:
           if (dataReady) begin
              state <= `STATE_START_BIT;
              dataBuf <= data;
           end
         `STATE_START_BIT: if (baudClk) state <= `STATE_BIT_0;
         `STATE_BIT_0: if (baudClk) state <= `STATE_BIT_1;
         `STATE_BIT_1: if (baudClk) state <= `STATE_BIT_2;
         `STATE_BIT_2: if (baudClk) state <= `STATE_BIT_3;
         `STATE_BIT_3: if (baudClk) state <= `STATE_BIT_4;
         `STATE_BIT_4: if (baudClk) state <= `STATE_BIT_5;
         `STATE_BIT_5: if (baudClk) state <= `STATE_BIT_6;
         `STATE_BIT_6: if (baudClk) state <= `STATE_BIT_7;
         `STATE_BIT_7: if (baudClk) state <= `STATE_STOP_BIT;
         `STATE_STOP_BIT: if (baudClk) state <= `STATE_IDLE;
         default: if(baudClk) state <= `STATE_STOPPED;
       endcase

   always @(state or dataBuf)
     case (state)
       `STATE_START_BIT: tx <= 0;
       `STATE_BIT_0: tx <= dataBuf[0];
       `STATE_BIT_1: tx <= dataBuf[1];
       `STATE_BIT_2: tx <= dataBuf[2];
       `STATE_BIT_3: tx <= dataBuf[3];
       `STATE_BIT_4: tx <= dataBuf[4];
       `STATE_BIT_5: tx <= dataBuf[5];
       `STATE_BIT_6: tx <= dataBuf[6];
       `STATE_BIT_7: tx <= dataBuf[7];
       default: tx <= 1;
     endcase

   always @(state)
     case (state)
       `STATE_IDLE: busy <= 0;
       `STATE_STOPPED: busy <= 0;
       default: busy <= 1;
     endcase
endmodule
