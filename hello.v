module hello(input clk_50, input reset_n, output tx);
   uart yuart(
         .clk(clk_50),
         .reset(reset_n),
         .tx(tx)
         );
endmodule
