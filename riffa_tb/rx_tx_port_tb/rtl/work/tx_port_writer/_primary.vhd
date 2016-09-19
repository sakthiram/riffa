library verilog;
use verilog.vl_types.all;
entity tx_port_writer is
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
        TXN_ERR         : out    vl_logic;
        TXN_DONE_ACK    : in     vl_logic;
        NEW_TXN         : in     vl_logic;
        NEW_TXN_ACK     : out    vl_logic;
        NEW_TXN_LAST    : in     vl_logic;
        NEW_TXN_LEN     : in     vl_logic_vector(31 downto 0);
        NEW_TXN_OFF     : in     vl_logic_vector(30 downto 0);
        NEW_TXN_WORDS_RECVD: in     vl_logic_vector(31 downto 0);
        NEW_TXN_DONE    : in     vl_logic;
        SG_ELEM_ADDR    : in     vl_logic_vector(63 downto 0);
        SG_ELEM_LEN     : in     vl_logic_vector(31 downto 0);
        SG_ELEM_RDY     : in     vl_logic;
        SG_ELEM_EMPTY   : in     vl_logic;
        SG_ELEM_REN     : out    vl_logic;
        SG_RST          : out    vl_logic;
        SG_ERR          : in     vl_logic;
        TX_REQ          : out    vl_logic;
        TX_REQ_ACK      : in     vl_logic;
        TX_ADDR         : out    vl_logic_vector(63 downto 0);
        TX_LEN          : out    vl_logic_vector(9 downto 0);
        TX_LAST         : out    vl_logic;
        TX_SENT         : in     vl_logic
    );
end tx_port_writer;
