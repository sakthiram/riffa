library verilog;
use verilog.vl_types.all;
entity \register\ is
    generic(
        C_WIDTH         : integer := 1;
        C_VALUE         : integer := 0
    );
    port(
        CLK             : in     vl_logic;
        RST_IN          : in     vl_logic;
        RD_DATA         : out    vl_logic_vector;
        WR_DATA         : in     vl_logic_vector;
        WR_EN           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of C_VALUE : constant is 1;
end \register\;
