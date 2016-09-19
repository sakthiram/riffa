library verilog;
use verilog.vl_types.all;
entity rx_port_channel_gate is
    generic(
        C_DATA_WIDTH    : vl_logic_vector(0 to 8) := (Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        RST             : in     vl_logic;
        CLK             : in     vl_logic;
        RX              : in     vl_logic;
        RX_RECVD        : out    vl_logic;
        RX_ACK_RECVD    : out    vl_logic;
        RX_LAST         : in     vl_logic;
        RX_LEN          : in     vl_logic_vector(31 downto 0);
        RX_OFF          : in     vl_logic_vector(30 downto 0);
        RX_CONSUMED     : out    vl_logic_vector(31 downto 0);
        RD_DATA         : in     vl_logic_vector;
        RD_EMPTY        : in     vl_logic;
        RD_EN           : out    vl_logic;
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
end rx_port_channel_gate;
