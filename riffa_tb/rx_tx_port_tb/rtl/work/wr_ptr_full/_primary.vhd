library verilog;
use verilog.vl_types.all;
entity wr_ptr_full is
    generic(
        C_DEPTH_BITS    : integer := 4
    );
    port(
        WR_CLK          : in     vl_logic;
        WR_RST          : in     vl_logic;
        WR_EN           : in     vl_logic;
        WR_FULL         : out    vl_logic;
        WR_PTR          : out    vl_logic_vector;
        WR_PTR_P1       : out    vl_logic_vector;
        CMP_FULL        : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_DEPTH_BITS : constant is 1;
end wr_ptr_full;
