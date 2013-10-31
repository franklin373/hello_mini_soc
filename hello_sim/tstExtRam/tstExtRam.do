transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_altera {D:/workProjNoSync/hello_mini_soc/hello_altera/sram/sram_sync32_async16.v}
#vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_altera {D:/workProjNoSync/hello_mini_soc/hello_altera/sram_extern_32.v}
#vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_altera {D:/workProjNoSync/hello_mini_soc/hello_altera/sram_conv_32_16.v}
#vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_altera {D:/workProjNoSync/hello_mini_soc/hello_altera/sram_extern_16.v}
#vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_altera {D:/workProjNoSync/hello_mini_soc/hello_altera/gpio_bus.v}
#vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_altera {D:/workProjNoSync/hello_mini_soc/hello_altera/rxtx_bus.v}
#vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_altera {D:/workProjNoSync/hello_mini_soc/hello_altera/led0_module.v}
#vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_altera {D:/workProjNoSync/hello_mini_soc/hello_altera/arm9_compatiable_code.v}
#vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_altera {D:/workProjNoSync/hello_mini_soc/hello_altera/hello_soc_top.v}
#vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_altera {D:/workProjNoSync/hello_mini_soc/hello_altera/rom.v}
#vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_altera {D:/workProjNoSync/hello_mini_soc/hello_altera/pll.v}
#vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_altera {D:/workProjNoSync/hello_mini_soc/hello_altera/includes.v}
#vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_altera/db {D:/workProjNoSync/hello_mini_soc/hello_altera/db/pll_altpll.v}
#vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_altera {D:/workProjNoSync/hello_mini_soc/hello_altera/rxtx.v}

#vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_altera/simulation/modelsim {D:/workProjNoSync/hello_mini_soc/hello_altera/simulation/modelsim/hello_soc_top.vt}
vlog -vlog01compat -work work +incdir+D:/workProjNoSync/hello_mini_soc/hello_sim/tstExtRam {D:/workProjNoSync/hello_mini_soc/hello_sim/tstExtRam/tstExtRam.vt}

#vsim -t 1ns -L altera_ver -L lnm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tstExtRam
vsim -t 1ns  -L work -voptargs="+acc"  tstExtRam

add wave -group "top" clk_50m			\
						rst_n
add wave -group "bus_32" 					\
						i1/state_next		\
						i1/state			\
						i1/iSync32_address	\
						i1/iSync32_byteena	\
						i1/iSync32_data		\
						i1/iSync32_wren		\
						i1/iSync32_ce		\
						i1/oSync32_q		\
						i1/ocSync32_wait
add wave -group "ram_16" 						\
						i1/oAsync16_address		\
						i1/oAsync16_byteena_n	\
						i1/oAsync16_data		\
						i1/oAsync16_data_oe_tri	\
						i1/oAsync16_wren_n		\
						i1/oAsync16_ce_n		\
						i1/oAsync16_oe_n		\
						i1/iAsync16_q		
#add wave -group "conv" i1/conv/stage_next	\
#						i1/conv/stage
#add wave -group "mid_16" i1/address_16	\
#						i1/byteena_16	\
#						i1/data_16		\
#						i1/wren_16		\
#						i1/ce_16		\
#						i1/q_16			\
#						i1/wait_16
#add wave -group "ram_16" i1/address_ram	\
#						i1/byteena_ram	\
#						i1/data_ram		\
#						i1/data_oe_tri	\
#						i1/wren_ram		\
#						i1/ce_ram		\
#						i1/oe_ram		\
#						i1/q_ram
view structure
view signals
run -all
