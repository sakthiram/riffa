// abstract class interface
package probe_pkg;
import uvm_pkg::*;
  virtual class probe_abstract #(type T=int) extends uvm_object;
    function new(string name="");
      super.new(name);
    endfunction
    // the API for the internal probe
    pure virtual function T get_probe();
    pure virtual function void set_probe(T Data );
    pure virtual task edge_probe(bit Edge=1);
  endclass : probe_abstract
endpackage : probe_pkg

// This interface will be bound inside the DUT and provides the concrete class defintion.
interface probe_itf #(int WIDTH) (inout wire [WIDTH-1:0] WData);
import uvm_pkg::*;
  typedef logic [WIDTH-1:0] T;
  T Data_reg = 'z;
  assign WData = Data_reg;
  import probe_pkg::*;
  // String used for factory by_name registration
  localparam string PATH = $psprintf("%m");
  // concrete class
  class probe extends probe_abstract #(T);
    function new(string name="");
      super.new(name);
    endfunction // new

    typedef uvm_object_registry #(probe,{"probe_",PATH}) type_id;

    static function type_id get_type();
      return type_id::get();
    endfunction

    // provide the implementations for the pure methods
    function T get_probe();
      return WData;
    endfunction

    function void set_probe(T Data );
      Data_reg = Data;
    endfunction

    task edge_probe(bit Edge=1);
      @(WData iff (WData === Edge));
    endtask

  endclass : probe
endinterface : probe_itf
