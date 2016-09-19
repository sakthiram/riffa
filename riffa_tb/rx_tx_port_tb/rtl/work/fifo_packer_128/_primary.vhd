library verilog;
use verilog.vl_types.all;
entity fifo_packer_128 is
    port(
        CLK             : in     vl_logic;
        RST             : in     vl_logic;
        DATA_IN         : in     vl_logic_vector(127 downto 0);
        DATA_IN_EN      : in     vl_logic_vector(2 downto 0);
        DATA_IN_DONE    : in     vl_logic;
        DATA_IN_ERR     : in     vl_logic;
        DATA_IN_FLUSH   : in     vl_logic;
        PACKED_DATA     : out    vl_logic_vector(127 downto 0);
        PACKED_WEN      : out    vl_logic;
        PACKED_DATA_DONE: out    vl_logic;
        PACKED_DATA_ERR : out    vl_logic;
        PACKED_DATA_FLUSHED: out    vl_logic
    );
end fifo_packer_128;
