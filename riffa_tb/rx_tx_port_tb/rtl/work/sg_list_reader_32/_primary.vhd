library verilog;
use verilog.vl_types.all;
entity sg_list_reader_32 is
    generic(
        C_DATA_WIDTH    : vl_logic_vector(0 to 8) := (Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        CLK             : in     vl_logic;
        RST             : in     vl_logic;
        BUF_DATA        : in     vl_logic_vector;
        BUF_DATA_EMPTY  : in     vl_logic;
        BUF_DATA_REN    : out    vl_logic;
        VALID           : out    vl_logic;
        EMPTY           : out    vl_logic;
        REN             : in     vl_logic;
        ADDR            : out    vl_logic_vector(63 downto 0);
        LEN             : out    vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of C_DATA_WIDTH : constant is 1;
end sg_list_reader_32;
