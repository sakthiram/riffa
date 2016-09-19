library verilog;
use verilog.vl_types.all;
entity rx_port_reader is
    generic(
        C_DATA_WIDTH    : vl_logic_vector(0 to 8) := (Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        C_FIFO_DEPTH    : integer := 1024;
        C_MAX_READ_REQ  : integer := 2;
        C_DATA_WORD_WIDTH: vl_notype;
        C_FIFO_WORDS    : vl_notype
    );
    port(
        CLK             : in     vl_logic;
        RST             : in     vl_logic;
        CONFIG_MAX_READ_REQUEST_SIZE: in     vl_logic_vector(2 downto 0);
        TXN_DATA        : in     vl_logic_vector(31 downto 0);
        TXN_LEN_VALID   : in     vl_logic;
        TXN_OFF_LAST_VALID: in     vl_logic;
        TXN_DONE_LEN    : out    vl_logic_vector(31 downto 0);
        TXN_DONE        : out    vl_logic;
        TXN_ERR         : out    vl_logic;
        TXN_DONE_ACK    : in     vl_logic;
        TXN_DATA_FLUSH  : out    vl_logic;
        TXN_DATA_FLUSHED: in     vl_logic;
        RX_REQ          : out    vl_logic;
        RX_ADDR         : out    vl_logic_vector(63 downto 0);
        RX_LEN          : out    vl_logic_vector(9 downto 0);
        RX_REQ_ACK      : in     vl_logic;
        RX_DATA_EN      : in     vl_logic_vector;
        RX_DONE         : in     vl_logic;
        RX_ERR          : in     vl_logic;
        SG_DONE         : in     vl_logic;
        SG_ERR          : in     vl_logic;
        SG_ELEM_ADDR    : in     vl_logic_vector(63 downto 0);
        SG_ELEM_LEN     : in     vl_logic_vector(31 downto 0);
        SG_ELEM_RDY     : in     vl_logic;
        SG_ELEM_REN     : out    vl_logic;
        SG_RST          : out    vl_logic;
        CHNL_RX         : out    vl_logic;
        CHNL_RX_LEN     : out    vl_logic_vector(31 downto 0);
        CHNL_RX_LAST    : out    vl_logic;
        CHNL_RX_OFF     : out    vl_logic_vector(30 downto 0);
        CHNL_RX_RECVD   : in     vl_logic;
        CHNL_RX_ACK_RECVD: in     vl_logic;
        CHNL_RX_CONSUMED: in     vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of C_FIFO_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of C_MAX_READ_REQ : constant is 1;
    attribute mti_svvh_generic_type of C_DATA_WORD_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of C_FIFO_WORDS : constant is 3;
end rx_port_reader;
