library verilog;
use verilog.vl_types.all;
entity mem_pipeline is
    generic(
        C_DEPTH         : integer := 10;
        C_WIDTH         : integer := 10;
        C_PIPELINE_INPUT: integer := 0;
        C_PIPELINE_OUTPUT: integer := 1
    );
    port(
        CLK             : in     vl_logic;
        RST_IN          : in     vl_logic;
        WR_DATA         : in     vl_logic_vector;
        WR_DATA_VALID   : in     vl_logic;
        WR_DATA_READY   : out    vl_logic;
        RD_DATA         : out    vl_logic_vector;
        RD_DATA_VALID   : out    vl_logic;
        RD_DATA_READY   : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of C_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of C_PIPELINE_INPUT : constant is 1;
    attribute mti_svvh_generic_type of C_PIPELINE_OUTPUT : constant is 1;
end mem_pipeline;
