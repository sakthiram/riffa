`timescale 1ns/100ps 
//--------------
// module tb_top
//--------------
module tb_top;
  `include "defines.svh"
  import uvm_pkg::*;
  import tb_pkg::*;
  import test_pkg::*;

  reg CLK = 0;
  reg RST = 1;
  reg CHNL_RX_CLK = 0;
  reg CHNL_TX_CLK = 0;
  wire [`DATA_WORD_WIDTH-1:0] SG_RX_DATA_EN = 0;
  wire SG_RX_DONE = 0;
  wire SG_RX_ERR = 0;
  wire [`DATA_WORD_WIDTH-1:0] SG_TX_DATA_EN = 0;
  wire SG_TX_DONE = 0;
  wire SG_TX_ERR = 0;
  wire [`DATA_WORD_WIDTH-1:0] MAIN_DATA_EN = 0;
  wire MAIN_DONE = 0;
  wire MAIN_ERR = 0;
  wire [`DATA_WIDTH-1:0] ENG_DATA;
  wire	[63:0]	SG_ELEM_ADDR;
  wire [31:0]	SG_ELEM_LEN;

  // Instantiate the interface
  top_if dut_if_inst(
   .CLK(CLK),
   .RST(RST),
   .CHNL_RX_CLK(CHNL_RX_CLK),
   .CHNL_TX_CLK(CHNL_TX_CLK),
   .SG_RX_DATA_EN(SG_RX_DATA_EN),
   .SG_RX_DONE(SG_RX_DONE),
   .SG_RX_ERR(SG_RX_ERR),
   .SG_TX_DATA_EN(SG_TX_DATA_EN),
   .SG_TX_DONE(SG_TX_DONE),
   .SG_TX_ERR(SG_TX_ERR),
   .MAIN_DATA_EN(MAIN_DATA_EN),
   .MAIN_DONE(MAIN_DONE),
   .MAIN_ERR(MAIN_ERR),
   .ENG_DATA(ENG_DATA),
   .SG_ELEM_ADDR(SG_ELEM_ADDR),
   .SG_ELEM_LEN(SG_ELEM_LEN)
  );

  // Instantiate DUT & connect it to the interface
  top dut(.dut_if(dut_if_inst));

  // Generate clock
  initial begin
  	CLK = 0;
  	#100;
  	forever #2.5 CLK = ~CLK;
  end
  
  initial begin
    CHNL_RX_CLK = 0;
  	#100;
  	forever #1.5 CHNL_RX_CLK = ~CHNL_RX_CLK;
  end
  
  initial begin
    CHNL_TX_CLK = 0;
  	#100;
  	forever #1.5 CHNL_TX_CLK = ~CHNL_TX_CLK;
  end
  
  // Generate reset
  initial begin
  	RST = 0;
  	#100;
  	RST = 1;
  	#5;
  	RST = 0;
  end
  
  initial begin
    // Place the interface into the UVM configuration database
    uvm_config_db#(virtual top_if)::set(null, "*", "dut_vif", dut_if_inst);
    // Start the test
    run_test();
  end
  
  initial begin
    // Dump waves
    //$dumpfile("dump.vcd");
    //$dumpvars(0, tb_top);
    //$dumpvars(0, tb_top.dut.rxPort);
  end
  
endmodule
