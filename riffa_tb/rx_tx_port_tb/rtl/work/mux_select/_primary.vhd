library verilog;
use verilog.vl_types.all;
entity mux_select is
    generic(
        C_NUM_INPUTS    : integer := 4;
        C_CLOG_NUM_INPUTS: integer := 2;
        C_WIDTH         : integer := 32
    );
    port(
        MUX_INPUTS      : in     vl_logic_vector;
        MUX_SELECT      : in     vl_logic_vector;
        MUX_OUTPUT      : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_NUM_INPUTS : constant is 1;
    attribute mti_svvh_generic_type of C_CLOG_NUM_INPUTS : constant is 1;
    attribute mti_svvh_generic_type of C_WIDTH : constant is 1;
end mux_select;
