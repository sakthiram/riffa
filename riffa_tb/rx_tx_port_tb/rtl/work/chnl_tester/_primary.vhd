library verilog;
use verilog.vl_types.all;
entity chnl_tester is
    generic(
        C_PCI_DATA_WIDTH: vl_logic_vector(0 to 8) := (Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        CLK             : in     vl_logic;
        RST             : in     vl_logic;
        CHNL_RX_CLK     : out    vl_logic;
        CHNL_RX         : in     vl_logic;
        CHNL_RX_ACK     : out    vl_logic;
        CHNL_RX_LAST    : in     vl_logic;
        CHNL_RX_LEN     : in     vl_logic_vector(31 downto 0);
        CHNL_RX_OFF     : in     vl_logic_vector(30 downto 0);
        CHNL_RX_DATA    : in     vl_logic_vector;
        CHNL_RX_DATA_VALID: in     vl_logic;
        CHNL_RX_DATA_REN: out    vl_logic;
        CHNL_TX_CLK     : out    vl_logic;
        CHNL_TX         : out    vl_logic;
        CHNL_TX_ACK     : in     vl_logic;
        CHNL_TX_LAST    : out    vl_logic;
        CHNL_TX_LEN     : out    vl_logic_vector(31 downto 0);
        CHNL_TX_OFF     : out    vl_logic_vector(30 downto 0);
        CHNL_TX_DATA    : out    vl_logic_vector;
        CHNL_TX_DATA_VALID: out    vl_logic;
        CHNL_TX_DATA_REN: in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_PCI_DATA_WIDTH : constant is 1;
end chnl_tester;
