rm -rf work 
vlib work 
ls ../rtl/*.v | xargs -L 1 vlog -sv +incdir+../rtl 
vlog -sv +incdir+../rtl +incdir+../tb_env ../tb_env/top.sv ../tb_env/tb_env.sv  ../tests/test_addr_len_and_main_data_from_rx_port.sv -timescale 1ns/1ns 
vlog -sv +incdir+../rtl +incdir+../tb_env ../tb_env/top.sv ../tb_env/tb_top.sv  -timescale 1ns/1ns 
vsim -do "vsim -voptargs=+acc work.tb_top +UVM_TESTNAME=test_addr_len_and_main_data_from_rx_port -sv_seed 4102368143 +UVM_VERBOSITY=UVM_HIGH -do wave.do; run -all" 
