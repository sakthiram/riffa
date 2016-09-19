library verilog;
use verilog.vl_types.all;
entity rx_port_requester_mux is
    port(
        RST             : in     vl_logic;
        CLK             : in     vl_logic;
        SG_RX_REQ       : in     vl_logic;
        SG_RX_LEN       : in     vl_logic_vector(9 downto 0);
        SG_RX_ADDR      : in     vl_logic_vector(63 downto 0);
        SG_RX_REQ_PROC  : out    vl_logic;
        SG_TX_REQ       : in     vl_logic;
        SG_TX_LEN       : in     vl_logic_vector(9 downto 0);
        SG_TX_ADDR      : in     vl_logic_vector(63 downto 0);
        SG_TX_REQ_PROC  : out    vl_logic;
        MAIN_REQ        : in     vl_logic;
        MAIN_LEN        : in     vl_logic_vector(9 downto 0);
        MAIN_ADDR       : in     vl_logic_vector(63 downto 0);
        MAIN_REQ_PROC   : out    vl_logic;
        RX_REQ          : out    vl_logic;
        RX_REQ_ACK      : in     vl_logic;
        RX_REQ_TAG      : out    vl_logic_vector(1 downto 0);
        RX_REQ_ADDR     : out    vl_logic_vector(63 downto 0);
        RX_REQ_LEN      : out    vl_logic_vector(9 downto 0);
        REQ_ACK         : out    vl_logic
    );
end rx_port_requester_mux;
