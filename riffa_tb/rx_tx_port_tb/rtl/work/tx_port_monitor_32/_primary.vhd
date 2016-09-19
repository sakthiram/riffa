library verilog;
use verilog.vl_types.all;
entity tx_port_monitor_32 is
    generic(
        C_DATA_WIDTH    : vl_logic_vector(0 to 8) := (Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0);
        C_FIFO_DEPTH    : integer := 512;
        C_FIFO_DEPTH_THRESH: vl_notype;
        C_FIFO_DEPTH_WIDTH: vl_notype;
        C_VALID_HIST    : integer := 1
    );
    port(
        RST             : in     vl_logic;
        CLK             : in     vl_logic;
        EVT_DATA        : in     vl_logic_vector;
        EVT_DATA_EMPTY  : in     vl_logic;
        EVT_DATA_RD_EN  : out    vl_logic;
        WR_DATA         : out    vl_logic_vector;
        WR_EN           : out    vl_logic;
        WR_COUNT        : in     vl_logic_vector;
        TXN             : out    vl_logic;
        ACK             : in     vl_logic;
        LAST            : out    vl_logic;
        LEN             : out    vl_logic_vector(31 downto 0);
        OFF             : out    vl_logic_vector(30 downto 0);
        WORDS_RECVD     : out    vl_logic_vector(31 downto 0);
        DONE            : out    vl_logic;
        TX_ERR          : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of C_FIFO_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of C_FIFO_DEPTH_THRESH : constant is 3;
    attribute mti_svvh_generic_type of C_FIFO_DEPTH_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of C_VALID_HIST : constant is 1;
end tx_port_monitor_32;
