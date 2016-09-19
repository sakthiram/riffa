library verilog;
use verilog.vl_types.all;
entity shiftreg is
    generic(
        C_DEPTH         : integer := 10;
        C_WIDTH         : integer := 32;
        C_VALUE         : integer := 0
    );
    port(
        CLK             : in     vl_logic;
        RST_IN          : in     vl_logic;
        WR_DATA         : in     vl_logic_vector;
        RD_DATA         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of C_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of C_VALUE : constant is 1;
end shiftreg;
