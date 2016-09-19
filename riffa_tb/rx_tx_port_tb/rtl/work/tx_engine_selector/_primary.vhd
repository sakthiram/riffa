library verilog;
use verilog.vl_types.all;
entity tx_engine_selector is
    generic(
        C_NUM_CHNL      : vl_logic_vector(0 to 3) := (Hi1, Hi1, Hi0, Hi0)
    );
    port(
        CLK             : in     vl_logic;
        RST             : in     vl_logic;
        REQ_ALL         : in     vl_logic_vector;
        REQ             : out    vl_logic;
        CHNL            : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_NUM_CHNL : constant is 1;
end tx_engine_selector;
