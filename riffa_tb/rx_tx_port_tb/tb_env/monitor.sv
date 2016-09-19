class sg_list_packet extends uvm_sequence_item;

  `uvm_object_utils(sg_list_packet)

  bit [63:0] addr;
  bit [31:0] len;

  function new (string name = "");
    super.new(name);
  endfunction

  virtual function string convert2string();
     convert2string = {
       $sformatf(" addr=%8h data=%8h ",addr,len)};
  endfunction

endclass: sg_list_packet 

class wr_monitor extends uvm_monitor;

    `uvm_component_utils(wr_monitor)

    string fifo_type;
    uvm_analysis_port#(sg_list_packet) sg_wr_ap;
    
    virtual top_if dut_vif;

    function new(string name, uvm_component parent);
       super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
      // Get interface reference from config database
      if(!uvm_config_db#(virtual top_if)::get(this, "", "dut_vif", dut_vif)) begin
        `uvm_error("", "uvm_config_db::get failed")
      end
      sg_wr_ap = new(.name("sg_wr_ap"), .parent(this));
    endfunction

    task run_phase(uvm_phase phase);
       bit [4*32+`DATA_WIDTH-1:0] circular_buffer; // since max of {8/12} DW outstanding is possible for {128/256} 
       bit [`DATA_WORD_WIDTH:0] c_buf_pos_start = 0;
       bit [`DATA_WORD_WIDTH:0] c_buf_pos_end = 0;
       forever begin
          sg_list_packet sg_pkt;
          int word_count = 0;
          int size = 0, start_point = c_buf_pos_start;
          //sg_pkt = new();
          sg_pkt = sg_list_packet::type_id::create("sg_pkt");

          // CLK is used for all fifo wr
          @(negedge dut_vif.CLK);

          // SG_RX
          if (fifo_type == "SG_RX") begin
            while(dut_vif.SG_RX_DATA_EN == 0) @(negedge dut_vif.CLK);
            // Append to circular_buffer
            while (word_count < dut_vif.SG_RX_DATA_EN) begin
                circular_buffer[c_buf_pos_end*32 +: 31] = dut_vif.ENG_DATA[word_count*32 +: 31];
                c_buf_pos_end = (c_buf_pos_end+1)%(`DATA_WIDTH/32+4);
                word_count += 1;
            end
            // Circular Buffer Size Calc
            while (start_point != c_buf_pos_end) begin
                start_point = (start_point + 1)%(`DATA_WIDTH/32+4);
                size += 1;
            end
            // Add to pkt analysis port if 4 DW availble
            while (size >= 4) begin
                sg_pkt.addr[31:0] = circular_buffer[c_buf_pos_start*32 +: 31];
                c_buf_pos_start = (c_buf_pos_start + 1)%(`DATA_WIDTH/32+4);
                sg_pkt.addr[63:32] = circular_buffer[c_buf_pos_start*32 +: 31];
                c_buf_pos_start = (c_buf_pos_start + 1)%(`DATA_WIDTH/32+4);
                sg_pkt.len = circular_buffer[c_buf_pos_start*32 +: 31];
                c_buf_pos_start = (c_buf_pos_start + 2)%(`DATA_WIDTH/32+4);
                sg_wr_ap.write(sg_pkt);
                size -= 4;
            end

          end

          // SG_TX

      
       end // forever
    endtask: run_phase


endclass: wr_monitor

class sg_wr_sb_subscriber extends uvm_subscriber#(sg_list_packet);
   `uvm_component_utils(sg_wr_sb_subscriber)
 
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new
 
   function void write(sg_list_packet t);
     uvm_table_printer p = new;
     `uvm_info("sg_wr_sb_subscriber",
                       { "Writing sg_packet.\n", t.sprint(p) }, UVM_LOW);       
   endfunction: write
endclass: sg_wr_sb_subscriber 

class rd_monitor extends uvm_monitor;

    `uvm_component_utils(rd_monitor)

    string fifo_type;
    uvm_analysis_port#(sg_list_packet) sg_rd_ap;
    
    virtual top_if dut_vif;

    function new(string name, uvm_component parent);
       super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
      // Get interface reference from config database
      if(!uvm_config_db#(virtual top_if)::get(this, "", "dut_vif", dut_vif)) begin
        `uvm_error("", "uvm_config_db::get failed")
      end
      sg_rd_ap = new(.name("sg_rd_ap"), .parent(this));
    endfunction

    task run_phase(uvm_phase phase);
       forever begin
          sg_list_packet sg_pkt;
          logic ren;
          //sg_pkt = new();
          sg_pkt = sg_list_packet::type_id::create("sg_pkt");

          // SG_RX
          if (fifo_type == "SG_RX") begin
            @(negedge dut_vif.CLK);
            uvm_hdl_read("tb_top.dut.rxPort.wSgElemRen", ren);
            while(ren == 0) begin
                @(negedge dut_vif.CLK);
                uvm_hdl_read("tb_top.dut.rxPort.wSgElemRen", ren);
            end

            uvm_hdl_read("tb_top.dut.rxPort.wSgElemAddr", sg_pkt.addr);
            uvm_hdl_read("tb_top.dut.rxPort.wSgElemLen", sg_pkt.len);
                sg_rd_ap.write(sg_pkt);
          end

          // SG_TX
          else if (fifo_type == "SG_TX") begin
            @(negedge dut_vif.CLK);
          end
     
          // MAIN
          else if (fifo_type == "MAIN") begin
            @(negedge dut_vif.CHNL_RX_CLK);
          end
      
      end // forever
    endtask: run_phase


endclass: rd_monitor

class sg_rd_sb_subscriber extends uvm_subscriber#(sg_list_packet);
   `uvm_component_utils(sg_rd_sb_subscriber)
 
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new
 
   function void write(sg_list_packet t);
     uvm_table_printer p = new;
     `uvm_info("sg_rd_sb_subscriber",
                       { "Reading sg_packet.\n", t.sprint(p) }, UVM_LOW);       
   endfunction: write
endclass: sg_rd_sb_subscriber 

