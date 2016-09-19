class wr_driver extends uvm_driver #(wr_transaction);

  `uvm_component_utils(wr_driver)

  string fifo_type;
  // Getting error: "Illegal non-integral expression in random constraint"
  //constraint c_fifo_type { fifo_type == "SG_RX"; } // Default
  virtual top_if dut_vif;
  wr_transaction wr_req;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Get interface reference from config database
    if(!uvm_config_db#(virtual top_if)::get(this, "", "dut_vif", dut_vif)) begin
      `uvm_error("", "uvm_config_db::get failed")
    end
  endfunction 

  task run_phase(uvm_phase phase);
    // First toggle reset
    //dut_vif.reset = 1;
    //@(posedge dut_vif.clock);
    //#1;
    //dut_vif.reset = 0;
    @(posedge dut_vif.CLK);
    
    // Now drive normal traffic
    forever begin
      seq_item_port.get_next_item(wr_req);

      // Wiggle pins of DUT
      if(fifo_type == "SG_RX") begin
          uvm_hdl_force("tb_top.SG_RX_DATA_EN", wr_req.data_en);
      end
      else if(fifo_type == "SG_TX") begin
          uvm_hdl_force("tb_top.SG_TX_DATA_EN", wr_req.data_en);
      end
      else if(fifo_type == "MAIN") begin
          uvm_hdl_force("tb_top.MAIN_DATA_EN", wr_req.data_en);
      end
      uvm_hdl_force("tb_top.ENG_DATA", wr_req.data);

      @(posedge dut_vif.CLK);
      if(fifo_type == "SG_RX") begin
          uvm_hdl_release("tb_top.SG_RX_DATA_EN");
      end
      else if(fifo_type == "SG_TX") begin
          uvm_hdl_release("tb_top.SG_TX_DATA_EN");
      end
      else if(fifo_type == "MAIN") begin
          uvm_hdl_release("tb_top.MAIN_DATA_EN");
      end
      uvm_hdl_release("tb_top.ENG_DATA");

      seq_item_port.item_done();
    end
  endtask

endclass: wr_driver

class rd_driver extends uvm_driver #(rd_transaction);

  `uvm_component_utils(rd_driver)

  string fifo_type;
  // Getting error: "Illegal non-integral expression in random constraint"
  //constraint c_fifo_type { fifo_type == "SG_RX"; } // Default
  virtual top_if dut_vif;
  rd_transaction rd_req;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Get interface reference from config database
    if(!uvm_config_db#(virtual top_if)::get(this, "", "dut_vif", dut_vif)) begin
      `uvm_error("", "uvm_config_db::get failed")
    end
  endfunction 

  task run_phase(uvm_phase phase);
    // First toggle reset
    //dut_vif.reset = 1;
    //@(posedge dut_vif.clock);
    //#1;
    //dut_vif.reset = 0;
    logic ready;
    logic fifo_empty;

    // Now drive normal traffic
    forever begin
      seq_item_port.get_next_item(rd_req);

      // Wiggle pins of DUT -- rx_port_reader logic
      if(fifo_type == "SG_RX") begin
          @(posedge dut_vif.CLK);
          uvm_hdl_read("tb_top.dut.rxPort.wSgElemRdy", ready);
          while(ready != 1) begin
              @(posedge dut_vif.CLK);
              uvm_hdl_read("tb_top.dut.rxPort.wSgElemRdy", ready);
          end
          uvm_hdl_force("tb_top.dut.rxPort.wSgElemRen", 1);
      end
      else if(fifo_type == "SG_TX") begin
          @(posedge dut_vif.CLK);
          uvm_hdl_read("tb_top.dut.txPort.wSgElemRdy", ready);
          while(ready != 1) begin
              @(posedge dut_vif.CLK);
              uvm_hdl_read("tb_top.dut.txPort.wSgElemRdy", ready);
          end
          uvm_hdl_force("tb_top.dut.txPort.wSgElemRen", 1);
      end
      else if(fifo_type == "MAIN") begin
          @(posedge dut_vif.CHNL_RX_CLK);
          uvm_hdl_read("tb_top.dut.rxPort.wMainDataEmpty", fifo_empty);
          while (fifo_empty) begin
            @(posedge dut_vif.CHNL_RX_CLK);
            uvm_hdl_read("tb_top.dut.rxPort.wMainDataEmpty", fifo_empty);
          end
          uvm_hdl_force("tb_top.dut.CHNL_RX_DATA_REN", 1);
          while (!fifo_empty) begin
            @(posedge dut_vif.CHNL_RX_CLK);
            uvm_hdl_read("tb_top.dut.rxPort.wMainDataEmpty", fifo_empty);
          end
      end

      if(fifo_type == "SG_RX") begin
          @(posedge dut_vif.CLK);
          uvm_hdl_force("tb_top.dut.rxPort.wSgElemRen", 0);
      end
      else if(fifo_type == "SG_TX") begin
          @(posedge dut_vif.CLK);
          uvm_hdl_force("tb_top.dut.txPort.wSgElemRen", 0);
      end
      else if(fifo_type == "MAIN") begin
          @(posedge dut_vif.CLK);
          uvm_hdl_force("tb_top.dut.CHNL_RX_DATA_REN", 0);
      end


      seq_item_port.item_done();
    end
  endtask

endclass: rd_driver

