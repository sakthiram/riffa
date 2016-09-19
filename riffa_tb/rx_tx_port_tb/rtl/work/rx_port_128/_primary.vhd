library verilog;
use verilog.vl_types.all;
entity rx_port_128 is
    generic(
        C_DATA_WIDTH    : vl_logic_vector(0 to 8) := (Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        C_MAIN_FIFO_DEPTH: integer := 1024;
        C_SG_FIFO_DEPTH : integer := 512;
        C_MAX_READ_REQ  : integer := 2;
        C_DATA_WORD_WIDTH: vl_notype;
        C_MAIN_FIFO_DEPTH_WIDTH: vl_notype;
        C_SG_FIFO_DEPTH_WIDTH: vl_notype
    );
    port(
        CLK             : in     vl_logic;
        RST             : in     vl_logic;
        CONFIG_MAX_READ_REQUEST_SIZE: in     vl_logic_vector(2 downto 0);
        SG_RX_BUF_RECVD : out    vl_logic;
        SG_RX_BUF_DATA  : in     vl_logic_vector(31 downto 0);
        SG_RX_BUF_LEN_VALID: in     vl_logic;
        SG_RX_BUF_ADDR_HI_VALID: in     vl_logic;
        SG_RX_BUF_ADDR_LO_VALID: in     vl_logic;
        SG_TX_BUF_RECVD : out    vl_logic;
        SG_TX_BUF_DATA  : in     vl_logic_vector(31 downto 0);
        SG_TX_BUF_LEN_VALID: in     vl_logic;
        SG_TX_BUF_ADDR_HI_VALID: in     vl_logic;
        SG_TX_BUF_ADDR_LO_VALID: in     vl_logic;
        SG_DATA         : out    vl_logic_vector;
        SG_DATA_EMPTY   : out    vl_logic;
        SG_DATA_REN     : in     vl_logic;
        SG_RST          : in     vl_logic;
        SG_ERR          : out    vl_logic;
        TXN_DATA        : in     vl_logic_vector(31 downto 0);
        TXN_LEN_VALID   : in     vl_logic;
        TXN_OFF_LAST_VALID: in     vl_logic;
        TXN_DONE_LEN    : out    vl_logic_vector(31 downto 0);
        TXN_DONE        : out    vl_logic;
        TXN_DONE_ACK    : in     vl_logic;
        RX_REQ          : out    vl_logic;
        RX_REQ_ACK      : in     vl_logic;
        RX_REQ_TAG      : out    vl_logic_vector(1 downto 0);
        RX_REQ_ADDR     : out    vl_logic_vector(63 downto 0);
        RX_REQ_LEN      : out    vl_logic_vector(9 downto 0);
        MAIN_DATA       : in     vl_logic_vector;
        MAIN_DATA_EN    : in     vl_logic_vector;
        MAIN_DONE       : in     vl_logic;
        MAIN_ERR        : in     vl_logic;
        SG_RX_DATA      : in     vl_logic_vector;
        SG_RX_DATA_EN   : in     vl_logic_vector;
        SG_RX_DONE      : in     vl_logic;
        SG_RX_ERR       : in     vl_logic;
        SG_TX_DATA      : in     vl_logic_vector;
        SG_TX_DATA_EN   : in     vl_logic_vector;
        SG_TX_DONE      : in     vl_logic;
        SG_TX_ERR       : in     vl_logic;
        CHNL_CLK        : in     vl_logic;
        CHNL_RX         : out    vl_logic;
        CHNL_RX_ACK     : in     vl_logic;
        CHNL_RX_LAST    : out    vl_logic;
        CHNL_RX_LEN     : out    vl_logic_vector(31 downto 0);
        CHNL_RX_OFF     : out    vl_logic_vector(30 downto 0);
        CHNL_RX_DATA    : out    vl_logic_vector;
        CHNL_RX_DATA_VALID: out    vl_logic;
        CHNL_RX_DATA_REN: in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of C_MAIN_FIFO_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of C_SG_FIFO_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of C_MAX_READ_REQ : constant is 1;
    attribute mti_svvh_generic_type of C_DATA_WORD_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of C_MAIN_FIFO_DEPTH_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of C_SG_FIFO_DEPTH_WIDTH : constant is 3;
end rx_port_128;
