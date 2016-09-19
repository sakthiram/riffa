library verilog;
use verilog.vl_types.all;
entity tx_port_channel_gate_128 is
    generic(
        C_DATA_WIDTH    : vl_logic_vector(0 to 8) := (Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        C_FIFO_DEPTH    : integer := 8;
        C_FIFO_DATA_WIDTH: vl_notype
    );
    port(
        RST             : in     vl_logic;
        RD_CLK          : in     vl_logic;
        RD_DATA         : out    vl_logic_vector;
        RD_EMPTY        : out    vl_logic;
        RD_EN           : in     vl_logic;
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
    attribute mti_svvh_generic_type of C_FIFO_DATA_WIDTH : constant is 3;
end tx_port_channel_gate_128;
