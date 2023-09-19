module fifo_memory_tb;
  parameter ADDR_SIZE = 3;
  parameter DEPTH = 8;
  parameter DATA_SIZE = 8;

  reg clk;
  reg rst;
  reg [DEPTH-1:0] data_in;
  reg WE;
  reg RE;
  wire [DEPTH-1:0] data_out;

  reg [DEPTH-1:0] data = 0;
  reg [ADDR_SIZE-1:0]temp_rd_ptr;

  fifo_memory #(
                .ADDR_SIZE(ADDR_SIZE),
                .DEPTH(DEPTH),
                .DATA_SIZE(DATA_SIZE)
              ) dut (
                .clk(clk),
                .rst(rst),
                .data_in(data_in),
                .WE(WE),
                .RE(RE),
                .data_out(data_out)
              );

  always
  begin
    #5 clk = ~clk;
  end

  initial
  begin
    $dumpfile("fifo_memory_waveform.vcd");
    $dumpvars(0, fifo_memory_tb);
    $display("Starting FIFO Memory Controller Testbench");

    clk = 0;
    rst = 1;
    data_in = 8'h00;
    WE = 0;
    RE = 0;

    #10;
    rst = 0;
    #10;

    // Write 9 data to the FIFO, last one will fail as FIFO is full
    repeat (9)
    begin
      WE = 1;
      data = data +1;
      data_in = data;
      #10;
    end
    WE = 0;
    data_in = 8'h00;

    #10;

    // Read 3 data from the FIFO
    repeat (3)
    begin
      RE = 1;
      #10;
    end
    RE = 0;
    #10;

    // Write 3 data to the FIFO, it will start again from zero
    // as last time the write pointer had reached last memory location (0x07)
    repeat (4)
    begin
      WE = 1;
      data = data +1;
      data_in = data;
      #10;
    end
    WE = 0;
    data_in = 8'h00;

    // Read 9 data from the FIFO, 9th will fail as after 8 reads FIFO will be empty
    repeat (9)
    begin
      RE = 1;
      #10;
    end
    RE = 0;
    #10;

    //Check simultaneous read and write
    WE = 1;
    data = data +1;
    data_in = data;
    #10;
    repeat (4)
    begin
      RE = 1;
      data = data +1;
      data_in = data;
      #10;
    end
    WE = 0;
    RE = 0;
    data_in = 8'h00;

    #10;
    $finish;
  end

  always @(posedge clk)
  begin
    if (RE)
    begin
      if (dut.st[1])
        $display("Reading Data: Can't read data, FIFO memory empty\n");
      else
      begin
        temp_rd_ptr = dut.rd_ptr;
        #5;
        $display("Reading Data: data_out = Ox%h from rd_ptr = %b, st = %b\n", data_out, temp_rd_ptr, dut.st);

      end
    end
    if (WE)
    begin
      if (dut.st[0])
        $display("Writing Data: Can't write data, FIFO memory full\n");
      else
        $display("Writing Data: data_in = Ox%h, at wr_ptr = %b,  st = %b\n", data_in, dut.wr_ptr, dut.st );
    end
  end

endmodule
