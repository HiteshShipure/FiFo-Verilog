module fifo(clk,rst,buf_in,buf_out,wr_en,rd_en,buf_empty,buf_full,fifo_counter,wr_pt,rd_pt);
  input clk,rst,wr_en,rd_en;
  input [7:0] buf_in;
  output reg [7:0] buf_out,fifo_counter;
  output reg [3:0] wr_pt,rd_pt;
  output reg buf_full, buf_empty;
  reg [7:0] buf_mem [63:0];
  
  always@(posedge clk or posedge rst) begin
  if(rst) begin
    buf_empty <= 1'b1;
    buf_full <= 1'b0;
  end else begin
    buf_empty <= (fifo_counter == 0) || (fifo_counter == 1 && rd_en && !wr_en);
    buf_full <= (fifo_counter == 63) || (fifo_counter == 62 && wr_en && !rd_en);
  end
  end

  
  always@(posedge clk or posedge rst)begin
    if(rst)
      fifo_counter<=0;
    else if(wr_en&&!buf_full&&rd_en&&!buf_empty)
      fifo_counter<=fifo_counter;
    else if(wr_en&&!buf_full)
      fifo_counter<=fifo_counter+1;
    else if(rd_en&&!buf_empty)
      fifo_counter<=fifo_counter-1;
    else
      fifo_counter<=fifo_counter;
  end
  
  always@(posedge clk or posedge rst)begin
    if(rst)
      buf_out<=0;
    else if(rd_en&&!buf_empty)
      buf_out<=buf_mem[rd_pt];
    else
      buf_out<=buf_out;
  end
  
  always@(posedge clk)begin
    if(wr_en&&!buf_full)
      buf_mem[wr_pt]<=buf_in;
    else
      buf_mem[wr_pt]<=buf_mem[wr_pt];
  end
  
  always@(posedge clk or posedge rst)begin
    if(rst)begin
      wr_pt<=0;
      rd_pt<=0;
    end
    else begin
      if(wr_en&&!buf_full)begin
        if(wr_pt==63)
          wr_pt<=0;
        else
          wr_pt<=wr_pt+1;
      end
      else
        wr_pt<=wr_pt;
      if(rd_en&&!buf_empty)begin
        if(rd_pt==63)
          rd_pt<=0;
        else
          rd_pt<=rd_pt+1;
      end
      else
        rd_pt<=rd_pt;
    end
  end
endmodule

     
     
     
     
     
    
  
    
    
    
    
  
