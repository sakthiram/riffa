library verilog;
use verilog.vl_types.all;
entity async_fifo_fwft is
    generic(
        C_WIDTH         : integer := 32;
        C_DEPTH         : integer := 1024;
        C_REAL_DEPTH    : vl_notype;
        C_DEPTH_BITS    : vl_notype;
        C_DEPTH_P1_BITS : vl_notype
    );
    port(
        RD_CLK          : in     vl_logic;
        RD_RST          : in     vl_logic;
        WR_CLK          : in     vl_logic;
        WR_RST          : in     vl_logic;
        WR_DATA         : in     vl_logic_vector;
        WR_EN           : in     vl_logic;
        RD_DATA         : out    vl_logic_vector;
        RD_EN           : in     vl_logic;
        WR_FULL         : out    vl_logic;
        RD_EMPTY        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of C_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of C_REAL_DEPTH : constant is 3;
    attribute mti_svvh_generic_type of C_DEPTH_BITS : constant is 3;
    attribute mti_svvh_generic_type of C_DEPTH_P1_BITS : constant is 3;
end async_fifo_fwft;
