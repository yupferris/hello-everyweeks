`define STATE_BYTE_START             3'h0
`define STATE_BYTE_WAIT_FOR_BUSY     3'h1
`define STATE_BYTE_WAIT_FOR_NOT_BUSY 3'h2
`define STATE_STOPPED                3'h3

`define MESSAGE "Hello, everyweeks!\r\n"
`define MESSAGE_LEN 20
`define MESSAGE_LEN_BITS `MESSAGE_LEN * 8

module hello(
             input  clk_50,
             input  reset_n,
             output tx);

   reg [7:0] data;
   reg       dataReady;

   wire      busy;

   reg [0:`MESSAGE_LEN_BITS - 1] message;

   reg [1:0] state;

   always @(posedge clk_50 or negedge reset_n)
     if (reset_n == 1'b0) begin
        data <= 0;
        dataReady <= 0;

        message <= `MESSAGE;
        state <= `STATE_BYTE_START;
     end else begin
        case (state)
          `STATE_BYTE_START:
            if (message[0:7] != 0) begin
               data <= message[0:7];
               message <= {message[8:`MESSAGE_LEN_BITS - 1], 8'd0};
               dataReady <= 1;
               state <= `STATE_BYTE_WAIT_FOR_BUSY;
            end else
              state <= `STATE_STOPPED;
          `STATE_BYTE_WAIT_FOR_BUSY:
            if (busy) begin
               dataReady <= 0;
               state <= `STATE_BYTE_WAIT_FOR_NOT_BUSY;
            end
          `STATE_BYTE_WAIT_FOR_NOT_BUSY:
            if (!busy)
              state <= `STATE_BYTE_START;
          default: state <= `STATE_STOPPED;
        endcase
     end

   uart yuart(
              .clk(clk_50),
              .reset(!reset_n),
              .data(data),
              .dataReady(dataReady),
              .busy(busy),
              .tx(tx)
              );
endmodule
