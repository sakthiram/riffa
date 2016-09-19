library verilog;
use verilog.vl_types.all;
entity tx_port_buffer_128 is
    generic(
        C_FIFO_DATA_WIDTH: vl_logic_vector(0 to 8) := (Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        C_FIFO_DEPTH    : integer := 512;
        C_FIFO_DEPTH_WIDTH: vl_notype;
        C_RD_EN_HIST    : integer := 2;
        C_FIFO_RD_EN_HIST: integer := 2;
        C_CONSUME_HIST  : integer := 3;
        C_COUNT_HIST    : integer := 3;
        C_LEN_LAST_HIST : integer := 1
    );
    port(
        RST             : in     vl_logic;
        CLK             : in     vl_logic;
        LEN_VALID       : in     vl_logic;
        LEN_LSB         : in     vl_logic_vector(1 downto 0);
        LEN_LAST        : in     vl_logic;
        WR_DATA         : in     vl_logic_vector;
        WR_EN           : in     vl_logic;
        WR_COUNT        : out    vl_logic_vector;
        RD_DATA         : out    vl_logic_vector;
        RD_EN           : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_FIFO_DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of C_FIFO_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of C_FIFO_DEPTH_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of C_RD_EN_HIST : constant is 1;
    attribute mti_svvh_generic_type of C_FIFO_RD_EN_HIST : constant is 1;
    attribute mti_svvh_generic_type of C_CONSUME_HIST : constant is 1;
    attribute mti_svvh_generic_type of C_COUNT_HIST : constant is 1;
    attribute mti_svvh_generic_type of C_LEN_LAST_HIST : constant is 1;
end tx_port_buffer_128;
