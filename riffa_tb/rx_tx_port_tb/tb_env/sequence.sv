`include "defines.svh"

class wr_transaction extends uvm_sequence_item;

  `uvm_object_utils(wr_transaction)

  rand bit [`DATA_WORD_WIDTH-1:0] data_en;
  rand bit [`DATA_WIDTH-1:0] data; 

  constraint c_data_en { data_en inside {[0:`DATA_WIDTH/32]}; } // default value
  //rand bit data_done; //TODO: Redundant for bits>=128
  //constraint c_data_done { soft data_done == 1; } // default value

  function new (string name = "");
    super.new(name);
  endfunction

endclass: wr_transaction

class wr_sequence extends uvm_sequence#(wr_transaction);

  `uvm_object_utils(wr_sequence)

  wr_transaction wr_req;

  function new (string name = "");
    super.new(name);
  endfunction

  task body;
    //repeat(8) begin
      wr_req = wr_transaction::type_id::create("wr_req");
      start_item(wr_req);

      if (!wr_req.randomize()) begin
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end

      // If using ModelSim, which does not support randomize(),
      // we must randomize item using traditional methods, like
      // wr_req.cmd = $urandom;
      // wr_req.addr = $urandom_range(0, 255);
      // wr_req.data = $urandom_range(0, 255);

      finish_item(wr_req);
    //end
  endtask: body

endclass: wr_sequence

class rd_transaction extends uvm_sequence_item;

  `uvm_object_utils(rd_transaction)

  rand bit rd_en;
  //constraint c_rd_en { rd_en == 1; } // default

  function new (string name = "");
    super.new(name);
  endfunction

endclass: rd_transaction

class rd_sequence extends uvm_sequence#(rd_transaction);

  `uvm_object_utils(rd_sequence)

  rd_transaction rd_req;
  rand bit rd_en;
  
  function new (string name = "");
    super.new(name);
  endfunction

  task body;
    //repeat(8) begin
      rd_req = rd_transaction::type_id::create("rd_req");
      start_item(rd_req);

      if (!rd_req.randomize() with { rd_en == local::rd_en; }) begin
        `uvm_error("MY_SEQUENCE", "Randomize failed.");
      end

      // If using ModelSim, which does not support randomize(),
      // we must randomize item using traditional methods, like
      // rd_req.cmd = $urandom;
      // rd_req.addr = $urandom_range(0, 255);
      // rd_req.data = $urandom_range(0, 255);

      finish_item(rd_req);
    //end
  endtask: body

endclass: rd_sequence

