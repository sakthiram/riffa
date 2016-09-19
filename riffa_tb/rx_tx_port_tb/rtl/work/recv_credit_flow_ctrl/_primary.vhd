library verilog;
use verilog.vl_types.all;
entity recv_credit_flow_ctrl is
    port(
        CLK             : in     vl_logic;
        RST             : in     vl_logic;
        CONFIG_MAX_READ_REQUEST_SIZE: in     vl_logic_vector(2 downto 0);
        CONFIG_MAX_CPL_DATA: in     vl_logic_vector(11 downto 0);
        CONFIG_MAX_CPL_HDR: in     vl_logic_vector(7 downto 0);
        CONFIG_CPL_BOUNDARY_SEL: in     vl_logic;
        RX_ENG_RD_DONE  : in     vl_logic;
        TX_ENG_RD_REQ_SENT: in     vl_logic;
        RXBUF_SPACE_AVAIL: out    vl_logic
    );
end recv_credit_flow_ctrl;
