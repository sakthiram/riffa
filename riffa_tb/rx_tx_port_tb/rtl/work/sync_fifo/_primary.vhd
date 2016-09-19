library verilog;
use verilog.vl_types.all;
entity sync_fifo is
    generic(
        C_WIDTH         : integer := 32;
        C_DEPTH         : integer := 1024;
        C_PROVIDE_COUNT : integer := 0;
        C_REAL_DEPTH    : vl_notype;
        C_DEPTH_BITS    : vl_notype;
        C_DEPTH_P1_BITS : vl_notype
    );
    port(
        CLK             : in     vl_logic;
        RST             : in     vl_logic;
        WR_DATA         : in     vl_logic_vector;
        WR_EN           : in     vl_logic;
        RD_DATA         : out    vl_logic_vector;
        RD_EN           : in     vl_logic;
        FULL            : out    vl_logic;
        EMPTY           : out    vl_logic;
        COUNT           : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of C_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of C_PROVIDE_COUNT : constant is 1;
    attribute mti_svvh_generic_type of C_REAL_DEPTH : constant is 3;
    attribute mti_svvh_generic_type of C_DEPTH_BITS : constant is 3;
    attribute mti_svvh_generic_type of C_DEPTH_P1_BITS : constant is 3;
end sync_fifo;
