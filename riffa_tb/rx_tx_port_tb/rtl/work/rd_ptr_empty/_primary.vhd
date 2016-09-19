library verilog;
use verilog.vl_types.all;
entity rd_ptr_empty is
    generic(
        C_DEPTH_BITS    : integer := 4
    );
    port(
        RD_CLK          : in     vl_logic;
        RD_RST          : in     vl_logic;
        RD_EN           : in     vl_logic;
        RD_EMPTY        : out    vl_logic;
        RD_PTR          : out    vl_logic_vector;
        RD_PTR_P1       : out    vl_logic_vector;
        CMP_EMPTY       : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_DEPTH_BITS : constant is 1;
end rd_ptr_empty;
