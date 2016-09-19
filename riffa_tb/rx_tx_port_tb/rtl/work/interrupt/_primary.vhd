library verilog;
use verilog.vl_types.all;
entity interrupt is
    generic(
        C_NUM_CHNL      : vl_logic_vector(0 to 3) := (Hi1, Hi1, Hi0, Hi0)
    );
    port(
        CLK             : in     vl_logic;
        RST             : in     vl_logic;
        RX_SG_BUF_RECVD : in     vl_logic_vector;
        RX_TXN_DONE     : in     vl_logic_vector;
        TX_TXN          : in     vl_logic_vector;
        TX_SG_BUF_RECVD : in     vl_logic_vector;
        TX_TXN_DONE     : in     vl_logic_vector;
        VECT_0_RST      : in     vl_logic;
        VECT_1_RST      : in     vl_logic;
        VECT_RST        : in     vl_logic_vector(31 downto 0);
        VECT_0          : out    vl_logic_vector(31 downto 0);
        VECT_1          : out    vl_logic_vector(31 downto 0);
        INTR_LEGACY_CLR : in     vl_logic;
        CONFIG_INTERRUPT_MSIENABLE: in     vl_logic;
        INTR_MSI_RDY    : in     vl_logic;
        INTR_MSI_REQUEST: out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_NUM_CHNL : constant is 1;
end interrupt;
