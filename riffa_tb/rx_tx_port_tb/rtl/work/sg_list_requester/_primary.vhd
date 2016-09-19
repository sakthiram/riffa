library verilog;
use verilog.vl_types.all;
entity sg_list_requester is
    generic(
        C_FIFO_DATA_WIDTH: vl_logic_vector(0 to 8) := (Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        C_FIFO_DEPTH    : integer := 1024;
        C_MAX_READ_REQ  : integer := 2;
        C_FIFO_DEPTH_WIDTH: vl_notype;
        C_WORDS_PER_ELEM: integer := 4;
        C_MAX_ELEMS     : integer := 200;
        C_MAX_ENTRIES   : vl_notype;
        C_FIFO_COUNT_THRESH: vl_notype
    );
    port(
        CLK             : in     vl_logic;
        RST             : in     vl_logic;
        CONFIG_MAX_READ_REQUEST_SIZE: in     vl_logic_vector(2 downto 0);
        USER_RST        : in     vl_logic;
        BUF_RECVD       : out    vl_logic;
        BUF_DATA        : in     vl_logic_vector(31 downto 0);
        BUF_LEN_VALID   : in     vl_logic;
        BUF_ADDR_HI_VALID: in     vl_logic;
        BUF_ADDR_LO_VALID: in     vl_logic;
        FIFO_COUNT      : in     vl_logic_vector;
        FIFO_FLUSH      : out    vl_logic;
        FIFO_FLUSHED    : in     vl_logic;
        FIFO_RST        : out    vl_logic;
        RX_REQ          : out    vl_logic;
        RX_ADDR         : out    vl_logic_vector(63 downto 0);
        RX_LEN          : out    vl_logic_vector(9 downto 0);
        RX_REQ_ACK      : in     vl_logic;
        RX_DONE         : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_FIFO_DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of C_FIFO_DEPTH : constant is 1;
    attribute mti_svvh_generic_type of C_MAX_READ_REQ : constant is 1;
    attribute mti_svvh_generic_type of C_FIFO_DEPTH_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of C_WORDS_PER_ELEM : constant is 1;
    attribute mti_svvh_generic_type of C_MAX_ELEMS : constant is 1;
    attribute mti_svvh_generic_type of C_MAX_ENTRIES : constant is 3;
    attribute mti_svvh_generic_type of C_FIFO_COUNT_THRESH : constant is 3;
end sg_list_requester;
