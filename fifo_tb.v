FIFO Testbench Module [EDA Playground + EPWave]
This document describes a self‑checking Verilog testbench for the 64‑depth, 8‑bit synchronous FIFO design, written to run on EDA Playground and view waves in EPWave.

Overview:-
The testbench instantiates the DUT as syncfifo with the same interface published in the RTL README and verifies typical and corner scenarios.
It produces a VCD file for EPWave and prints a live console trace for quick inspection during the run.

Features:-
Drives clock, synchronous reset, write/read enables, and 8‑bit data across reset, burst writes/reads, fill/empty, and concurrent operations.
Performs self‑checks with if/$error after each scenario using fifo_counter, buf_full, and buf_empty.
Generates EPWave‑ready waves via $dumpfile("dump.vcd") and $dumpvars(0, tbb_syncfifo_test) so EPWave opens automatically after Run.
Uses always #10 clk = ~clk for a 20‑time‑unit period, giving readable timing in EPWave.
Prints a $monitor line with the key signals and the current time for textual verification.

DUT Instance and Ports:-
The testbench wires clk, rst, wr_en, rd_en, buf_in[7:0], buf_out[7:0], buf_full, buf_empty, fifo_counter[7:0], wr_pt[3:0], and rd_pt[3:0] one‑to‑one to syncfifo uut.

  Stimulus Plan (Scenarios):-
Reset and bring‑up: assert rst for 20 time‑units, then deassert to start with clean pointers and counter.
Write burst (10 items): set wr_en=1 with random buf_in for 10 cycles, then expect fifo_counter==10.
Read burst (5 items): set rd_en=1 for 5 cycles, then expect fifo_counter==5.
Fill to capacity: issue 59 additional writes to reach full from count 5+59=64, then expect buf_full==1.
Drain to empty: read up to 64 cycles to fully drain, then expect buf_empty==1.
Simultaneous read & write (10 cycles): assert wr_en and rd_en together with random buf_in, validating legal concurrency.
Waveform 1 — Reset, 10 writes, then 5 reads (counter: 0 → 10 → 5)

This diagram illustrates the bring‑up and two burst phases that the testbench executes first:-

text
clk        ___     ___     ___     ___     ___     ___     ___     ___     ___     ___
         _|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |_
rst       _________
         |         |_______________________________________________________________
wr_en     __________/^^^^^^^^^^^^^^^^^^^^^^^^\______________________________________
                     (10 cycles high)
rd_en     ____________________________________/^^^^^\______________________________
                                              (5 cycles high)
buf_full  _________________________________________________________________________
buf_empty ^^^^^ (1 at reset) ____ ________________________________________________
fifo_cnt  00 01 02 03 04 05 06 07 08 09 10    09 08 07 06 05
Pass/Fail Checks

After the 10‑write burst, $error if fifo_counter !== 10.
After the 5‑read burst, $error if fifo_counter !== 5.
After filling, $error if buf_full !== 1.
After draining, $error if buf_empty !== 1.
On success, the console prints “All tests completed successfully.”.
  
Waveform 2 — Fill to FULL, drain to EMPTY, then 10 concurrent R/W (counter stable)
This diagram shows end‑conditions and the concurrent read/write phase with stable occupancy.

text
clk        ___     ___     ___     ___     ___     ___     ___     ___     ___     ___
         _|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |_
wr_en     __________/^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\__________/^^^^^\_____
                     (writes until FULL asserted)                         (concurrent)
rd_en     _________________________________________________/^^^^^^^^^^^^^^^^^^^^\____
                                                            (drain to EMPTY)     (concurrent)
buf_full  ________________________________/^^\_______________________________________
                                   (asserts at capacity)
buf_empty _____________________________________________/^^\_________________________
                                                  (asserts when empty)
fifo_cnt  ... 61 62 63 64                                63 62 61 ... 00  ~~~(stable)~~~
                                 FULL                                    EMPTY       (during concurrent R/W)
Waveforms and Console Tracing on EDA Playground:-
The testbench writes a VCD through $dumpfile/$dumpvars; enable “Open EPWave after run,” click Run, then use “Get Signals” in EPWave to add and view signals.
If EPWave says “No *.vcd file found,” ensure $dumpfile("dump.vcd") and $dumpvars(...) are in an initial block and that the testbench is the top.
Testbench Source (paste in the EDA Playground Testbench pane)

The snippet below is the exact TB used for the stimulus, waves, and checks:-
verilog
`timescale 1ns/1ps
module tbb_syncfifo_test;
  reg clk, rst, wr_en, rd_en;
  reg  [7:0] buf_in;
  wire [7:0] buf_out;
  wire [7:0] fifo_counter;
  wire       buf_full, buf_empty;
  wire [3:0] wr_pt, rd_pt;
  syncfifo uut (
    .clk(clk), .rst(rst),
    .wr_en(wr_en), .rd_en(rd_en),
    .buf_in(buf_in), .buf_out(buf_out),
    .buf_full(buf_full), .buf_empty(buf_empty),
    .fifo_counter(fifo_counter),
    .wr_pt(wr_pt), .rd_pt(rd_pt)
  );
  always #10 clk = ~clk;
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tbb_syncfifo_test);
  end
  initial begin
    clk=0; rst=1; wr_en=0; rd_en=0; buf_in=8'h00;
    #20 rst=0;
    $display("Test 1: Writing 10 elements");
    repeat(10) begin wr_en=1; buf_in=$random; #20; end
    wr_en=0;
    if (fifo_counter !== 10) $error("Test 1 Failed: FIFO counter incorrect");
    $display("Test 2: Reading 5 elements");
    repeat(5) begin rd_en=1; #20; end
    rd_en=0;
    if (fifo_counter !== 5) $error("Test 2 Failed: FIFO counter incorrect");
    $display("Test 3: Filling FIFO completely");
    repeat(59) begin wr_en=1; buf_in=$random; #20; end
    wr_en=0;
    if (buf_full !== 1) $error("Test 3 Failed: FIFO should be full");
    $display("Test 4: Emptying FIFO");
    repeat(64) begin rd_en=1; #20; end
    rd_en=0;
    if (buf_empty !== 1) $error("Test 4 Failed: FIFO should be empty");
    $display("Test 5: Simultaneous Read & Write");
    repeat(10) begin wr_en=1; rd_en=1; buf_in=$random; #20; end
    wr_en=0; rd_en=0;
    $display("All tests completed successfully.");
    $finish;
  end
  initial begin
    $monitor("Time=%0t | clk=%b | rst=%b | wr_en=%b | rd_en=%b | buf_in=%h | buf_out=%h | full=%b | empty=%b | counter=%0d",
             $time, clk, rst, wr_en, rd_en, buf_in, buf_out, buf_full, buf_empty, fifo_counter);
  end
endmodule
  
  How to Run on EDA Playground (EPWave):-
Paste your FIFO RTL (syncfifo.v) into the Design pane and this testbench into the Testbench pane so the testbench is the simulation top.
Select a Verilog/SystemVerilog simulator, check “Open EPWave after run,” and click Run to compile, simulate, and launch EPWave.
In EPWave, click “Get Signals,” add clk, rst, wr_en, rd_en, fifo_counter, buf_full, buf_empty, wr_pt, rd_pt, buf_in, buf_out; then zoom to the regions matching the two ASCII diagrams.
If waves don’t load, fix any compile/runtime errors, ensure the VCD dump calls are present, and rerun so EPWave receives dump.vcd.

  Expected Results Summary:-
After 10 writes: fifo_counter == 10 and neither buf_full nor buf_empty is asserted.
After 5 reads: fifo_counter == 5 with buf_out transitioning on valid reads from non‑empty.
After filling: buf_full == 1 and further writes are ignored while full.
After draining: buf_empty == 1 and reads from empty are ignored while buf_out stays stable.
During simultaneous read/write: occupancy remains stable while pointers advance appropriately.
