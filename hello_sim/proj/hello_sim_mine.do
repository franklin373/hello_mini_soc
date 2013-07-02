##############################################################################
# Source:    fcov.do
# Date:      August 23, 2006
# Modified:  September 20, 2006
# File:      Tcl simulation script for running Questa/ModelSim
# Remarks:   Questa 6.2 interleaver demo: SV Functional Coverage
##############################################################################
onbreak {resume}
if [file exists work] {
  vdel -all
}
vlib work
vlog -Epretty pp_result2.txt -suppress 2167 -suppress 2181 -sv -f compile_questa_sv.f
vopt +acc tb -o dbgver
vsim  -sv_lib vmm_str_dpi +nowarnTFMPC +vmm_test=tc dbgver
add wave -group "tb_top" 	/tb/clk		\
							/tb/rst		\
							/tb/rom_addr	\
							/tb/rom_data	\
							/tb/rom_en	\
							/tb/u_arm9/cha_rf_vld  \
							/tb/u_arm9/go_rf_vld   \
							/tb/u_arm9/hold_en     \
							/tb/u_arm9/int_all     \
							/tb/u_arm9/to_rf_vld   \
							/tb/u_arm9/wait_en
#add wave -group "UUB_RST DUT" /top_adaptor/uub_rst_if/*
#add wave -group "ISP1501_DUT" /top_adaptor/isp1501_if/*
#add wave -group "UTMI DUT" /top_adaptor/utmi_if/*
#add wave -group "Other" /top_adaptor/clk		\
#						/top_adaptor/utmi8_isp1501_adaptor_U1/isHigh		\
#						/top_adaptor/utmi8_isp1501_adaptor_U1/tx_valid_n	\
#						/top_adaptor/utmi8_isp1501_adaptor_U1/txoe
#add wave -group "rcv_intnl_if" /top/usbf_ro_top_U1/rcv_intnl_if_ins2/*
#add wave -group "Other" /top/wrt_trans_flag_latch 														\
#						/top/usbf_ro_top_U1/usbf_pd_U1/state					\
#						/top/usbf_ro_top_U1/usbf_buf_arbt_U3/errFlag_pid_n2 	\
#						/top/usbf_ro_top_U1/usbf_buf_arbt_U3/errFlag_pid_n1 	\
#						/top/usbf_ro_top_U1/usbf_buf_arbt_U3/errFlag_pid_0 	
#add wave -group "DataXX" -radix hex					\
#						/top/usbf_ro_top_U1/data0	\
#						/top/usbf_ro_top_U1/data1	\
#						/top/usbf_ro_top_U1/data2	\
#						/top/usbf_ro_top_U1/data3	\
#						/top/usbf_ro_top_U1/data4	\
#						/top/usbf_ro_top_U1/data5	\
#						/top/usbf_ro_top_U1/data6	\
#						/top/usbf_ro_top_U1/data7	\
#						/top/usbf_ro_top_U1/data8	\
#						/top/usbf_ro_top_U1/data9	\
#						/top/usbf_ro_top_U1/data10	\
#						/top/usbf_ro_top_U1/data11	\
#						/top/usbf_ro_top_U1/data12	\
#						/top/usbf_ro_top_U1/data13	\
#						/top/usbf_ro_top_U1/data14	\
#						/top/usbf_ro_top_U1/data15	
#add wave -group "ULPI DUT" /top/ulpi_if/*
#add wave -group "RegWrite_UlpiTrans_if" /top/a1/RegWrite_UlpiTrans_if_ins/*
#add wave -group "fifo_trans_in" /top/a1/fifo_trans_in/*
#add wave -group "FifoOut_if_trans" /top/a1/FifoOut_if_trans/*
#add wave -group "fifo_rcv_in" /top/a1/fifo_rcv_in/*
#add wave -group "FifoOut_if_rcv" /top/a1/FifoOut_if_rcv/*
#add wave -group "RegWrite_UlpiTrans_if_ins" /top/a1/RegWrite_UlpiTrans_if_ins/*
#add wave -group "temp" /top/a1/ULPI_trans_ins/transfer_count_pipe_comb /top/a1/ULPI_trans_ins/state \
#                       /top/a1/UTMI_trans_ins/state /top/a1/ULPI_rcv_ins/state \
#                       /top/a1/UTMI_rcv_ins/state /top/a1/RegWrite_ins/state
#configure wave -signalnamewidth 1
#bp DrvUlpiRcv4Test.sv 11 {if {$now /= 4} then {cont}}
run -all
fcover report -cvg -comments -option -file fcover_report.txt -r *


