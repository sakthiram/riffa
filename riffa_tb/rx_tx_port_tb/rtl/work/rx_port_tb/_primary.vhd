library verilog;
use verilog.vl_types.all;
entity rx_port_tb is
    generic(
        C_DATA_WIDTH    : vl_logic_vector(0 to 8) := (Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        C_MAX_READ_REQ  : integer := 2;
        C_RX_FIFO_DEPTH : integer := 1024;
        C_TX_FIFO_DEPTH : integer := 512;
        C_SG_FIFO_DEPTH : integer := 1024;
        C_DATA_WORD_WIDTH: vl_notype
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of C_MAX_READ_REQ : constant is 1;
    attribute mti_svvh_generic_type of C_RX_FIFO_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of C_TX_FIFO_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of C_SG_FIFO_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of C_DATA_WORD_WIDTH : constant is 3;
end rx_port_tb;
