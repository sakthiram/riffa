package tb_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  // The UVM sequence, transaction item, and driver are in these files:
  `include "sequence.sv"
  `include "driver.sv"
  `include "monitor.sv"
  `include "scoreboard.sv"

  // The agent contains sequencer, driver, and monitor (not included)
  class wr_agent extends uvm_agent;
    `uvm_component_utils(wr_agent)
    
    wr_driver driver;
    wr_monitor monitor;
    uvm_sequencer#(wr_transaction) sequencer;
    uvm_analysis_port#(sg_list_packet) sg_rx_wr_ap;
    sg_wr_sb_subscriber sg_rx_wr_sub;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      driver = wr_driver ::type_id::create("driver", this);
      monitor = wr_monitor ::type_id::create("monitor", this);
      sequencer =
        uvm_sequencer#(wr_transaction)::type_id::create("sequencer", this);
      sg_rx_wr_ap = new(.name("sg_rx_wr_ap"), .parent(this));
      sg_rx_wr_sub = new(.name("sg_rx_wr_sub"), .parent(this));
    endfunction    
    
    // In UVM connect phase, we connect the sequencer to the driver.
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
      monitor.sg_wr_ap.connect(sg_rx_wr_ap);
      monitor.sg_wr_ap.connect(sg_rx_wr_sub.analysis_export);
    endfunction
    
    /*
    task run_phase(uvm_phase phase);
      // We raise objection to keep the test from completing
      phase.raise_objection(this);
      begin
        wr_sequence seq;
        seq = wr_sequence::type_id::create("seq");
        seq.start(sequencer);
      end
      // We drop objection to allow the test to complete
      phase.drop_objection(this);
    endtask
    */

  endclass
  
  class rd_agent extends uvm_agent;
    `uvm_component_utils(rd_agent)
    
    rd_driver driver;
    rd_monitor monitor;
    uvm_sequencer#(rd_transaction) sequencer;
    uvm_analysis_port#(sg_list_packet) sg_rd_ap;
    sg_rd_sb_subscriber sg_rx_rd_sub;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      driver = rd_driver ::type_id::create("driver", this);
      monitor = rd_monitor ::type_id::create("monitor", this);
      sequencer =
        uvm_sequencer#(rd_transaction)::type_id::create("sequencer", this);
      sg_rd_ap = new(.name("sg_rd_ap"), .parent(this));
      sg_rx_rd_sub = new(.name("sg_rx_rd_sub"), .parent(this));
    endfunction    
    
    // In UVM connect phase, we connect the sequencer to the driver.
    function void connect_phase(uvm_phase phase);
      driver.seq_item_port.connect(sequencer.seq_item_export);
      monitor.sg_rd_ap.connect(sg_rd_ap);
      monitor.sg_rd_ap.connect(sg_rx_rd_sub.analysis_export);
    endfunction
    
  endclass
  
  //-------------------
  // environment tb_env
  //-------------------
  class tb_env extends uvm_env;
  
    wr_agent agent_sgrx_wr, agent_sgtx_wr, agent_main_wr;
    rd_agent agent_sgrx_rd, agent_sgtx_rd, agent_main_rd;
    sg_list_scoreboard sg_list_sb;
    `uvm_component_utils(tb_env)
  
    function new(string name, uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      agent_sgrx_wr = wr_agent::type_id::create("agent_sgrx_wr", this);
      agent_sgtx_wr = wr_agent::type_id::create("agent_sgtx_wr", this);
      agent_main_wr = wr_agent::type_id::create("agent_main_wr", this);
      agent_sgrx_rd = rd_agent::type_id::create("agent_sgrx_rd", this);
      agent_sgtx_rd = rd_agent::type_id::create("agent_sgtx_rd", this);
      agent_main_rd = rd_agent::type_id::create("agent_main_rd", this);
      sg_list_sb    = sg_list_scoreboard::type_id::create("sg_list_sb",this);
    endfunction

  
    function void connect_phase(uvm_phase phase);
      `uvm_info("LABEL", "Started connect phase.", UVM_HIGH);
       // SB connections
       agent_sgrx_wr.sg_rx_wr_ap.connect(sg_list_sb.expected_analysis_export);
       agent_sgrx_rd.sg_rd_ap.connect(sg_list_sb.actual_analysis_export);
      `uvm_info("LABEL", "Finished connect phase.", UVM_HIGH);
    endfunction: connect_phase
    
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info("LABEL", "Started run phase.", UVM_HIGH);
      begin
        agent_sgrx_wr.driver.fifo_type = "SG_RX";
        agent_sgrx_wr.monitor.fifo_type= "SG_RX";
        agent_sgtx_wr.driver.fifo_type = "SG_TX";
        agent_sgtx_wr.monitor.fifo_type= "SG_TX";
        agent_main_wr.driver.fifo_type = "MAIN";
        agent_main_wr.monitor.fifo_type= "MAIN";
        agent_sgrx_rd.driver.fifo_type = "SG_RX";
        agent_sgrx_rd.monitor.fifo_type= "SG_RX";
        agent_sgtx_rd.driver.fifo_type = "SG_TX";
        agent_sgtx_rd.monitor.fifo_type= "SG_TX";
        agent_main_rd.driver.fifo_type = "MAIN";
        agent_main_rd.monitor.fifo_type= "MAIN";
        //int a = 1'b1, b = 8'h3;
        //@(m_if.cb);
        //m_if.cb.SG_RX_DATA_EN <= a;
        //repeat(2) @(m_if.cb);
        //`uvm_info("RESULT", $sformatf("%0d + %0d = %0d",
        //  a, b, m_if.cb.result), UVM_LOW);
      end
      `uvm_info("LABEL", "Finished run phase.", UVM_HIGH);
      phase.drop_objection(this);
    endtask: run_phase
    
  endclass
 
endpackage
