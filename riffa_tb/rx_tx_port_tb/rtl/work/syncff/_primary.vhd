library verilog;
use verilog.vl_types.all;
entity syncff is
    port(
        CLK             : in     vl_logic;
        IN_ASYNC        : in     vl_logic;
        OUT_SYNC        : out    vl_logic
    );
end syncff;
