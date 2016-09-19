library verilog;
use verilog.vl_types.all;
entity interrupt_controller is
    port(
        CLK             : in     vl_logic;
        RST             : in     vl_logic;
        INTR            : in     vl_logic;
        INTR_LEGACY_CLR : in     vl_logic;
        INTR_DONE       : out    vl_logic;
        CONFIG_INTERRUPT_MSIENABLE: in     vl_logic;
        CFG_INTERRUPT_ASSERT: out    vl_logic;
        INTR_MSI_RDY    : in     vl_logic;
        INTR_MSI_REQUEST: out    vl_logic
    );
end interrupt_controller;
