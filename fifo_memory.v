module fifo_memory #(
    parameter ADDR_SIZE = 3,
    parameter DEPTH = 8,
    parameter DATA_SIZE = 8
  )(
    input clk, rst,
    input [DEPTH-1:0] data_in,
    input WE, RE,
    output reg [DEPTH-1:0] data_out
  );

  reg [DEPTH-1:0] mem [DATA_SIZE-1:0];
  reg [ADDR_SIZE-1:0] rd_ptr, wr_ptr,rd_addr, wr_addr;
  integer N;
  reg [1:0] st;

  integer i;

  always @(posedge clk or negedge rst)
  begin : FIFO_MEMORY
    if (~rst)
    begin
      for (i = 0 ; i < DEPTH; i = i + 1)
      begin
        mem[i] <= 8'b00000000;
      end
      data_out = 8'b00000000;
      rd_ptr = 3'b000;
      wr_ptr = 3'b000;
      N = 0;
      st = 2'b00;
    end
    else
    begin
      if (RE)
      begin : READ_CONTROLLER
        if (~st[1])
        begin
          data_out <= mem[rd_ptr];
          rd_ptr <= (rd_ptr + 1) % DEPTH;
          N = N - 1;
        end
      end

      if (WE)
      begin : WRITE_CONTROLLER
        if (~st[0])
        begin
          mem[wr_ptr] <= data_in;
          wr_ptr <= (wr_ptr + 1) % DEPTH;
          N = N + 1;
        end
      end

      begin : FIFO_CONTROLLER
        if (N == 0)
          st <= 2'b10;
        else if (N == DEPTH)
          st <= 2'b01;
        else
          st <= 2'b00;
      end

    end
  end

endmodule