class sg_list_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(sg_list_scoreboard)

    uvm_analysis_export#(sg_list_packet) expected_analysis_export;
    uvm_analysis_export#(sg_list_packet) actual_analysis_export;
    uvm_tlm_analysis_fifo#(sg_list_packet) expected_sg_list_fifo;
    uvm_tlm_analysis_fifo#(sg_list_packet) actual_sg_list_fifo;

   // Function: new
   //-------------------------------------------------------------------------
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new
 
   // Function: build_phase
   //-------------------------------------------------------------------------
   virtual function void build_phase( uvm_phase phase );
      super.build_phase( phase );
 
      expected_analysis_export = new( "expected_analysis_export", this );
        actual_analysis_export = new(   "actual_analysis_export", this );
      expected_sg_list_fifo    = new( "expected_sg_list_fifo", this );
        actual_sg_list_fifo    = new(   "actual_sg_list_fifo", this );
   endfunction: build_phase

   // Function: connect_phase
   //-------------------------------------------------------------------------
   virtual function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
 
      expected_analysis_export.connect( expected_sg_list_fifo.analysis_export );
        actual_analysis_export.connect(   actual_sg_list_fifo.analysis_export );
   endfunction: connect_phase

   virtual task run( );
      sg_list_packet expected_sg_list;
      sg_list_packet   actual_sg_list;
 
      forever begin
         expected_sg_list_fifo.get( expected_sg_list );
         `uvm_info("sg_list_scoreboard", "Main phase : Got wr packet", UVM_LOW)
           actual_sg_list_fifo.get(   actual_sg_list );
         `uvm_info("sg_list_scoreboard", "Main phase : Got Read packet", UVM_LOW)
         if ( expected_sg_list.compare( actual_sg_list ) == 0 ) begin
            `uvm_error( "main_phase", 
                        { "sg pkt mismatch: ",
                          "expected:", expected_sg_list.convert2string(),
                          "actual:",     actual_sg_list.convert2string() } )
         end
         else begin
            `uvm_info("sg_list_scoreboard", {"SG pkts matched:", actual_sg_list.convert2string() }, UVM_LOW)
         end

      end
   endtask: run 
 
   // Task: main_phase
   //-------------------------------------------------------------------------
   //virtual task main_phase( uvm_phase phase );
   //   sg_list_packet expected_sg_list;
   //   sg_list_packet   actual_sg_list;
 
   //   super.main_phase( phase );
   //   forever begin
   //      `uvm_info("sg_list_scoreboard", "ENTERED Main phase", UVM_LOW)
   //      expected_sg_list_fifo.get( expected_sg_list );
   //      `uvm_info("sg_list_scoreboard", "Main phase : Got wr packet", UVM_LOW)
   //        actual_sg_list_fifo.get(   actual_sg_list );
   //      `uvm_info("sg_list_scoreboard", "Main phase : Got Read packet", UVM_LOW)
   //      if ( expected_sg_list.compare( actual_sg_list ) == 0 ) begin
   //         `uvm_error( "main_phase", 
   //                     { "sg pkt mismatch: ",
   //                       "expected:", expected_sg_list.convert2string(),
   //                       "actual:",     actual_sg_list.convert2string() } )
   //      end
   //      else begin
   //         `uvm_info("sg_list_scoreboard", {"SG pkts matched:", actual_sg_list.convert2string() }, UVM_LOW)
   //      end


   //   end
   //endtask: main_phase
 
   // Function: extract_phase - checks leftover sg pkts in the FIFOs
   //-------------------------------------------------------------------------
   virtual function void extract_phase( uvm_phase phase );
      sg_list_packet sg_pkt;
 
      super.extract_phase( phase );
      if ( expected_sg_list_fifo.try_get( sg_pkt ) ) begin
         `uvm_error( "expected_sg_list_fifo", 
                     { "found a leftover sg pkt: ", sg_pkt.convert2string() } )
      end
 
      if ( actual_sg_list_fifo.try_get( sg_pkt ) ) begin
         `uvm_error( "actual_sg_list_fifo",
                     { "found a leftover sg_pkt: ", sg_pkt.convert2string() } )
      end
   endfunction: extract_phase
endclass: sg_list_scoreboard 

