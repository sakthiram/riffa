library verilog;
use verilog.vl_types.all;
entity cross_domain_signal is
    port(
        CLK_A           : in     vl_logic;
        CLK_A_SEND      : in     vl_logic;
        CLK_A_RECV      : out    vl_logic;
        CLK_B           : in     vl_logic;
        CLK_B_RECV      : out    vl_logic;
        CLK_B_SEND      : in     vl_logic
    );
end cross_domain_signal;
