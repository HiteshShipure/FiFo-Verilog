module fifo(clk, rst, buf_in, buf_out, wr_en, rd_en, buf_empty, buf_full, fifo_counter, wr_pt, rd_pt);
  // Input signals
  input clk, rst, wr_en, rd_en;
  input [7:0] buf_in;

  // Output signals
  output reg [7:0] buf_out, fifo_counter;
  output reg [3:0] wr_pt, rd_pt;
  output reg buf_full, buf_empty;

  // Internal memory for FIFO storage
  reg [7:0] buf_mem [63:0];

  //----------------------------------------------------------------------
  // Empty and Full Flag Logic
  //----------------------------------------------------------------------
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      buf_empty <= 1'b1; // Initialize empty flag on reset
      buf_full <= 1'b0;  // Initialize full flag on reset
    end else begin
      // Empty condition: counter is 0 or 1 and we are reading but not writing
      buf_empty <= (fifo_counter == 0) || (fifo_counter == 1 && rd_en && !wr_en);
      // Full condition: counter is 63 or 62 and we are writing but not reading
      buf_full <= (fifo_counter == 63) || (fifo_counter == 62 && wr_en && !rd_en);
    end
  end

  //----------------------------------------------------------------------
  // FIFO Counter Logic
  //----------------------------------------------------------------------
  always @(posedge clk or posedge rst) begin
    if (rst)
      fifo_counter <= 0; // Initialize counter on reset
    else if (wr_en && !buf_full && rd_en && !buf_empty)
      fifo_counter <= fifo_counter; // No change if writing and reading simultaneously (and not full/empty)
    else if (wr_en && !buf_full)
      fifo_counter <= fifo_counter + 1; // Increment counter on write (if not full)
    else if (rd_en && !buf_empty)
      fifo_counter <= fifo_counter - 1; // Decrement counter on read (if not empty)
    else
      fifo_counter <= fifo_counter; // No change in other cases
  end

  //----------------------------------------------------------------------
  // Output Data Logic
  //----------------------------------------------------------------------
  always @(posedge clk or posedge rst) begin
    if (rst)
      buf_out <= 0; // Initialize output on reset
    else if (rd_en && !buf_empty)
      buf_out <= buf_mem[rd_pt]; // Read data from memory if reading and not empty
    else
      buf_out <= buf_out;       // Hold previous output value
  end

  //----------------------------------------------------------------------
  // Memory Write Logic
  //----------------------------------------------------------------------
  always @(posedge clk) begin
    if (wr_en && !buf_full)
      buf_mem[wr_pt] <= buf_in; // Write input data to memory (if not full)
    else
      buf_mem[wr_pt] <= buf_mem[wr_pt]; // Hold previous memory value (no write)
  end

  //----------------------------------------------------------------------
  // Write and Read Pointer Logic
  //----------------------------------------------------------------------
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      wr_pt <= 0; // Initialize write pointer on reset
      rd_pt <= 0; // Initialize read pointer on reset
    end else begin
      // Write pointer update
      if (wr_en && !buf_full) begin
        if (wr_pt == 63)
          wr_pt <= 0;    // Wrap around to 0 if at the end of the buffer
        else
          wr_pt <= wr_pt + 1; // Increment write pointer
      end else
        wr_pt <= wr_pt;    // Hold previous write pointer value

      // Read pointer update
      if (rd_en && !buf_empty) begin
        if (rd_pt == 63)
          rd_pt <= 0;    // Wrap around to 0 if at the end of the buffer
        else
          rd_pt <= rd_pt + 1; // Increment read pointer
      end else
        rd_pt <= rd_pt;    // Hold previous read pointer value
    end
  end

endmodule
