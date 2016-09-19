package test_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;
import tb_pkg::*;

class test_addr_len_and_main_data_from_rx_port extends uvm_test;

  `uvm_component_utils(test_addr_len_and_main_data_from_rx_port)
  
  tb_env env;
  virtual top_if dut_vif;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    env = tb_env::type_id::create("env", this);
    if(!uvm_config_db#(virtual top_if)::get(this, "", "dut_vif", dut_vif)) begin
      `uvm_error("", "uvm_config_db::get failed")
    end
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #10;
    `uvm_info("", "Hello World Start", UVM_MEDIUM)
    begin

        // write can happen to only one of the three at one time (sg_rx/sg_tx/main)
        wr_sequence seq;
        // read can happen simulataneously across all three
        rd_sequence rd_seq_sg_rx;
        rd_sequence rd_seq_sg_tx;
        rd_sequence rd_seq_main;

        while (dut_vif.RST == 1) @(posedge dut_vif.CLK);
        repeat(10) @(posedge dut_vif.CLK);    

        fork 
            begin // 1
                repeat(8) begin
                   seq = wr_sequence::type_id::create("seq");
                   seq.start(env.agent_sgrx_wr.sequencer);
                   seq.start(env.agent_sgtx_wr.sequencer);
                   seq.start(env.agent_main_wr.sequencer);
                end
            end
            begin // 2a
                repeat(8) begin
                   rd_seq_sg_rx = rd_sequence::type_id::create("rd_seq_sg_rx");
                   rd_seq_sg_rx.start(env.agent_sgrx_rd.sequencer);
                end
            end
            begin // 2b
                repeat(8) begin
                   rd_seq_sg_tx = rd_sequence::type_id::create("rd_seq_sg_tx");
                   rd_seq_sg_tx.start(env.agent_sgtx_rd.sequencer);
                end
            end
            begin // 2c
                while (1) begin
                   rd_seq_main  = rd_sequence::type_id::create("rd_seq_main");
                   //if (!rd_seq_main.randomize() with { rd_en == 1; })
                   //  `uvm_fatal("RANDERR", "Randomization error")
                   rd_seq_main.start(env.agent_main_rd.sequencer);
                end
            end
        join_none

    end
    #300
    `uvm_info("", "Hello World End", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask
   
endclass: test_addr_len_and_main_data_from_rx_port
endpackage
