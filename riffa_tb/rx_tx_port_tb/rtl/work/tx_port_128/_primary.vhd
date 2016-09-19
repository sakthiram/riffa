library verilog;
use verilog.vl_types.all;
entity tx_port_128 is
    generic(
        C_DATA_WIDTH    : vl_logic_vector(0 to 8) := (Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        C_FIFO_DEPTH    : integer := 512;
        C_FIFO_DEPTH_WIDTH: vl_notype
    );
    port(
        CLK             : in     vl_logic;
        RST             : in     vl_logic;
        CONFIG_MAX_PAYLOAD_SIZE: in     vl_logic_vector(2 downto 0);
        TXN             : out    vl_logic;
        TXN_ACK         : in     vl_logic;
        TXN_LEN         : out    vl_logic_vector(31 downto 0);
        TXN_OFF_LAST    : out    vl_logic_vector(31 downto 0);
        TXN_DONE_LEN    : out    vl_logic_vector(31 downto 0);
        TXN_DONE        : out    vl_logic;
        TXN_DONE_ACK    : in     vl_logic;
        SG_DATA         : in     vl_logic_vector;
        SG_DATA_EMPTY   : in     vl_logic;
        SG_DATA_REN     : out    vl_logic;
        SG_RST          : out    vl_logic;
        SG_ERR          : in     vl_logic;
        TX_REQ          : out    vl_logic;
        TX_REQ_ACK      : in     vl_logic;
        TX_ADDR         : out    vl_logic_vector(63 downto 0);
        TX_LEN          : out    vl_logic_vector(9 downto 0);
        TX_DATA         : out    vl_logic_vector;
        TX_DATA_REN     : in     vl_logic;
        TX_SENT         : in     vl_logic;
        CHNL_CLK        : in     vl_logic;
        CHNL_TX         : in     vl_logic;
        CHNL_TX_ACK     : out    vl_logic;
        CHNL_TX_LAST    : in     vl_logic;
        CHNL_TX_LEN     : in     vl_logic_vector(31 downto 0);
        CHNL_TX_OFF     : in     vl_logic_vector(30 downto 0);
        CHNL_TX_DATA    : in     vl_logic_vector;
        CHNL_TX_DATA_VALID: in     vl_logic;
        CHNL_TX_DATA_REN: out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of C_FIFO_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of C_FIFO_DEPTH_WIDTH : constant is 3;
end tx_port_128;
