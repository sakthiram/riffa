library verilog;
use verilog.vl_types.all;
entity async_cmp is
    generic(
        C_DEPTH_BITS    : integer := 4;
        N               : vl_notype
    );
    port(
        WR_RST          : in     vl_logic;
        WR_CLK          : in     vl_logic;
        RD_RST          : in     vl_logic;
        RD_CLK          : in     vl_logic;
        RD_VALID        : in     vl_logic;
        WR_VALID        : in     vl_logic;
        EMPTY           : out    vl_logic;
        FULL            : out    vl_logic;
        WR_PTR          : in     vl_logic_vector;
        RD_PTR          : in     vl_logic_vector;
        WR_PTR_P1       : in     vl_logic_vector;
        RD_PTR_P1       : in     vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_DEPTH_BITS : constant is 1;
    attribute mti_svvh_generic_type of N : constant is 3;
end async_cmp;
