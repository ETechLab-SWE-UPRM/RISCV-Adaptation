## This is the main file for the pipeline implementation

## Clock signal
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]


## Switches
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports reset]
#set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]
#set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]
#set_property -dict { PACKAGE_PIN W17   IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]
#set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports {sw[4]}]
#set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports {sw[5]}]
#set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports {sw[6]}]
#set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports {sw[7]}]
#set_property -dict { PACKAGE_PIN V2    IOSTANDARD LVCMOS33 } [get_ports {sw[8]}]
#set_property -dict { PACKAGE_PIN T3    IOSTANDARD LVCMOS33 } [get_ports {sw[9]}]
#set_property -dict { PACKAGE_PIN T2    IOSTANDARD LVCMOS33 } [get_ports {sw[10]}]
#set_property -dict { PACKAGE_PIN R3    IOSTANDARD LVCMOS33 } [get_ports {sw[11]}]
#set_property -dict { PACKAGE_PIN W2    IOSTANDARD LVCMOS33 } [get_ports {sw[12]}]
#set_property -dict { PACKAGE_PIN U1    IOSTANDARD LVCMOS33 } [get_ports {sw[13]}]
#set_property -dict { PACKAGE_PIN T1    IOSTANDARD LVCMOS33 } [get_ports {sw[14]}]
#set_property -dict { PACKAGE_PIN R2    IOSTANDARD LVCMOS33 } [get_ports {sw[15]}]


## LEDs
#set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports led]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports {led2[0]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {led2[1]}]
set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports {led2[2]}]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {led2[3]}]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports {led2[4]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {led2[5]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {led2[6]}]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports {led2[7]}]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports led3]
#set_property -dict { PACKAGE_PIN W3    IOSTANDARD LVCMOS33 } [get_ports {led[10]}]
#set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 } [get_ports {led[11]}]
#set_property -dict { PACKAGE_PIN P3    IOSTANDARD LVCMOS33 } [get_ports {led[12]}]
#set_property -dict { PACKAGE_PIN N3    IOSTANDARD LVCMOS33 } [get_ports {led[13]}]
#set_property -dict { PACKAGE_PIN P1    IOSTANDARD LVCMOS33 } [get_ports {led[14]}]
set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports led4]


##7 Segment Display
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports {seg[0]}]
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33} [get_ports {seg[1]}]
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS33} [get_ports {seg[2]}]
set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33} [get_ports {seg[3]}]
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports {seg[4]}]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports {seg[5]}]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports {seg[6]}]

#set_property -dict { PACKAGE_PIN V7   IOSTANDARD LVCMOS33 } [get_ports dp]

set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports {an[0]}]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports {an[1]}]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports {an[2]}]
set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVCMOS33} [get_ports {an[3]}]


##Buttons
#set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports btnC]
#set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports btnU]
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports btn]
#set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports btnR]
#set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports btnD]


##Pmod Header JA
#set_property -dict { PACKAGE_PIN J1   IOSTANDARD LVCMOS33 } [get_ports {JA[0]}];#Sch name = JA1
#set_property -dict { PACKAGE_PIN L2   IOSTANDARD LVCMOS33 } [get_ports {JA[1]}];#Sch name = JA2
#set_property -dict { PACKAGE_PIN J2   IOSTANDARD LVCMOS33 } [get_ports {JA[2]}];#Sch name = JA3
#set_property -dict { PACKAGE_PIN G2   IOSTANDARD LVCMOS33 } [get_ports {JA[3]}];#Sch name = JA4
#set_property -dict { PACKAGE_PIN H1   IOSTANDARD LVCMOS33 } [get_ports {JA[4]}];#Sch name = JA7
#set_property -dict { PACKAGE_PIN K2   IOSTANDARD LVCMOS33 } [get_ports {JA[5]}];#Sch name = JA8
#set_property -dict { PACKAGE_PIN H2   IOSTANDARD LVCMOS33 } [get_ports {JA[6]}];#Sch name = JA9
#set_property -dict { PACKAGE_PIN G3   IOSTANDARD LVCMOS33 } [get_ports {JA[7]}];#Sch name = JA10

##Pmod Header JB
#set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33 } [get_ports {JB[0]}];#Sch name = JB1
#set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports {JB[1]}];#Sch name = JB2
#set_property -dict { PACKAGE_PIN B15   IOSTANDARD LVCMOS33 } [get_ports {JB[2]}];#Sch name = JB3
#set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33 } [get_ports {JB[3]}];#Sch name = JB4
#set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33 } [get_ports {JB[4]}];#Sch name = JB7
#set_property -dict { PACKAGE_PIN A17   IOSTANDARD LVCMOS33 } [get_ports {JB[5]}];#Sch name = JB8
#set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports {JB[6]}];#Sch name = JB9
#set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports {JB[7]}];#Sch name = JB10

##Pmod Header JC
#set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports {JC[0]}];#Sch name = JC1
#set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports {JC[1]}];#Sch name = JC2
#set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports {JC[2]}];#Sch name = JC3
#set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports {JC[3]}];#Sch name = JC4
#set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports {JC[4]}];#Sch name = JC7
#set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports {JC[5]}];#Sch name = JC8
#set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports {JC[6]}];#Sch name = JC9
#set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports {JC[7]}];#Sch name = JC10

##Pmod Header JXADC
#set_property -dict { PACKAGE_PIN J3   IOSTANDARD LVCMOS33 } [get_ports {JXADC[0]}];#Sch name = XA1_P
#set_property -dict { PACKAGE_PIN L3   IOSTANDARD LVCMOS33 } [get_ports {JXADC[1]}];#Sch name = XA2_P
#set_property -dict { PACKAGE_PIN M2   IOSTANDARD LVCMOS33 } [get_ports {JXADC[2]}];#Sch name = XA3_P
#set_property -dict { PACKAGE_PIN N2   IOSTANDARD LVCMOS33 } [get_ports {JXADC[3]}];#Sch name = XA4_P
#set_property -dict { PACKAGE_PIN K3   IOSTANDARD LVCMOS33 } [get_ports {JXADC[4]}];#Sch name = XA1_N
#set_property -dict { PACKAGE_PIN M3   IOSTANDARD LVCMOS33 } [get_ports {JXADC[5]}];#Sch name = XA2_N
#set_property -dict { PACKAGE_PIN M1   IOSTANDARD LVCMOS33 } [get_ports {JXADC[6]}];#Sch name = XA3_N
#set_property -dict { PACKAGE_PIN N1   IOSTANDARD LVCMOS33 } [get_ports {JXADC[7]}];#Sch name = XA4_N


##VGA Connector
#set_property -dict { PACKAGE_PIN G19   IOSTANDARD LVCMOS33 } [get_ports {vgaRed[0]}]
#set_property -dict { PACKAGE_PIN H19   IOSTANDARD LVCMOS33 } [get_ports {vgaRed[1]}]
#set_property -dict { PACKAGE_PIN J19   IOSTANDARD LVCMOS33 } [get_ports {vgaRed[2]}]
#set_property -dict { PACKAGE_PIN N19   IOSTANDARD LVCMOS33 } [get_ports {vgaRed[3]}]
#set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports {vgaBlue[0]}]
#set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports {vgaBlue[1]}]
#set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports {vgaBlue[2]}]
#set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports {vgaBlue[3]}]
#set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports {vgaGreen[0]}]
#set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports {vgaGreen[1]}]
#set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports {vgaGreen[2]}]
#set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports {vgaGreen[3]}]
#set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS33 } [get_ports Hsync]
#set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports Vsync]


##USB-RS232 Interface
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports rx]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports tx]


##USB HID (PS/2)
#set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33   PULLUP true } [get_ports PS2Clk]
#set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33   PULLUP true } [get_ports PS2Data]


##Quad SPI Flash
##Note that CCLK_0 cannot be placed in 7 series devices. You can access it using the
##STARTUPE2 primitive.
#set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[0]}]
#set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[1]}]
#set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[2]}]
#set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[3]}]
#set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports QspiCSn]


## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## SPI configuration mode options for QSPI boot, can be used for all designs
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]





# create_debug_core u_ila_0 ila
# set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
# set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
# set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
# set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
# set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
# set_property C_INPUT_PIPE_STAGES 1 [get_debug_cores u_ila_0]
# set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
# set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
# set_property port_width 1 [get_debug_ports u_ila_0/clk]
# connect_debug_port u_ila_0/clk [get_nets [list clk_IBUF_BUFG]]
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
# set_property port_width 32 [get_debug_ports u_ila_0/probe0]
# connect_debug_port u_ila_0/probe0 [get_nets [list {instruction[0]} {instruction[1]} {instruction[2]} {instruction[3]} {instruction[4]} {instruction[5]} {instruction[6]} {instruction[7]} {instruction[8]} {instruction[9]} {instruction[10]} {instruction[11]} {instruction[12]} {instruction[13]} {instruction[14]} {instruction[15]} {instruction[16]} {instruction[17]} {instruction[18]} {instruction[19]} {instruction[20]} {instruction[21]} {instruction[22]} {instruction[23]} {instruction[24]} {instruction[25]} {instruction[26]} {instruction[27]} {instruction[28]} {instruction[29]} {instruction[30]} {instruction[31]}]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
# set_property port_width 32 [get_debug_ports u_ila_0/probe1]
# connect_debug_port u_ila_0/probe1 [get_nets [list {pc[0]} {pc[1]} {pc[2]} {pc[3]} {pc[4]} {pc[5]} {pc[6]} {pc[7]} {pc[8]} {pc[9]} {pc[10]} {pc[11]} {pc[12]} {pc[13]} {pc[14]} {pc[15]} {pc[16]} {pc[17]} {pc[18]} {pc[19]} {pc[20]} {pc[21]} {pc[22]} {pc[23]} {pc[24]} {pc[25]} {pc[26]} {pc[27]} {pc[28]} {pc[29]} {pc[30]} {pc[31]}]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
# set_property port_width 32 [get_debug_ports u_ila_0/probe2]
# connect_debug_port u_ila_0/probe2 [get_nets [list {v_alu_result[1][0]} {v_alu_result[1][1]} {v_alu_result[1][2]} {v_alu_result[1][3]} {v_alu_result[1][4]} {v_alu_result[1][5]} {v_alu_result[1][6]} {v_alu_result[1][7]} {v_alu_result[1][8]} {v_alu_result[1][9]} {v_alu_result[1][10]} {v_alu_result[1][11]} {v_alu_result[1][12]} {v_alu_result[1][13]} {v_alu_result[1][14]} {v_alu_result[1][15]} {v_alu_result[1][16]} {v_alu_result[1][17]} {v_alu_result[1][18]} {v_alu_result[1][19]} {v_alu_result[1][20]} {v_alu_result[1][21]} {v_alu_result[1][22]} {v_alu_result[1][23]} {v_alu_result[1][24]} {v_alu_result[1][25]} {v_alu_result[1][26]} {v_alu_result[1][27]} {v_alu_result[1][28]} {v_alu_result[1][29]} {v_alu_result[1][30]} {v_alu_result[1][31]}]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
# set_property port_width 32 [get_debug_ports u_ila_0/probe3]
# connect_debug_port u_ila_0/probe3 [get_nets [list {v_alu_result[0][0]} {v_alu_result[0][1]} {v_alu_result[0][2]} {v_alu_result[0][3]} {v_alu_result[0][4]} {v_alu_result[0][5]} {v_alu_result[0][6]} {v_alu_result[0][7]} {v_alu_result[0][8]} {v_alu_result[0][9]} {v_alu_result[0][10]} {v_alu_result[0][11]} {v_alu_result[0][12]} {v_alu_result[0][13]} {v_alu_result[0][14]} {v_alu_result[0][15]} {v_alu_result[0][16]} {v_alu_result[0][17]} {v_alu_result[0][18]} {v_alu_result[0][19]} {v_alu_result[0][20]} {v_alu_result[0][21]} {v_alu_result[0][22]} {v_alu_result[0][23]} {v_alu_result[0][24]} {v_alu_result[0][25]} {v_alu_result[0][26]} {v_alu_result[0][27]} {v_alu_result[0][28]} {v_alu_result[0][29]} {v_alu_result[0][30]} {v_alu_result[0][31]}]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
# set_property port_width 32 [get_debug_ports u_ila_0/probe4]
# connect_debug_port u_ila_0/probe4 [get_nets [list {write_data[1][0]} {write_data[1][1]} {write_data[1][2]} {write_data[1][3]} {write_data[1][4]} {write_data[1][5]} {write_data[1][6]} {write_data[1][7]} {write_data[1][8]} {write_data[1][9]} {write_data[1][10]} {write_data[1][11]} {write_data[1][12]} {write_data[1][13]} {write_data[1][14]} {write_data[1][15]} {write_data[1][16]} {write_data[1][17]} {write_data[1][18]} {write_data[1][19]} {write_data[1][20]} {write_data[1][21]} {write_data[1][22]} {write_data[1][23]} {write_data[1][24]} {write_data[1][25]} {write_data[1][26]} {write_data[1][27]} {write_data[1][28]} {write_data[1][29]} {write_data[1][30]} {write_data[1][31]}]]
# create_debug_port u_ila_0 probe
# set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
# set_property port_width 32 [get_debug_ports u_ila_0/probe5]
# connect_debug_port u_ila_0/probe5 [get_nets [list {write_data[0][0]} {write_data[0][1]} {write_data[0][2]} {write_data[0][3]} {write_data[0][4]} {write_data[0][5]} {write_data[0][6]} {write_data[0][7]} {write_data[0][8]} {write_data[0][9]} {write_data[0][10]} {write_data[0][11]} {write_data[0][12]} {write_data[0][13]} {write_data[0][14]} {write_data[0][15]} {write_data[0][16]} {write_data[0][17]} {write_data[0][18]} {write_data[0][19]} {write_data[0][20]} {write_data[0][21]} {write_data[0][22]} {write_data[0][23]} {write_data[0][24]} {write_data[0][25]} {write_data[0][26]} {write_data[0][27]} {write_data[0][28]} {write_data[0][29]} {write_data[0][30]} {write_data[0][31]}]]
# set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
# set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
# set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
# connect_debug_port dbg_hub/clk [get_nets clk_IBUF_BUFG]


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 1 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 32 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {uart_data[0]} {uart_data[1]} {uart_data[2]} {uart_data[3]} {uart_data[4]} {uart_data[5]} {uart_data[6]} {uart_data[7]} {uart_data[8]} {uart_data[9]} {uart_data[10]} {uart_data[11]} {uart_data[12]} {uart_data[13]} {uart_data[14]} {uart_data[15]} {uart_data[16]} {uart_data[17]} {uart_data[18]} {uart_data[19]} {uart_data[20]} {uart_data[21]} {uart_data[22]} {uart_data[23]} {uart_data[24]} {uart_data[25]} {uart_data[26]} {uart_data[27]} {uart_data[28]} {uart_data[29]} {uart_data[30]} {uart_data[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {rec_data[0]} {rec_data[1]} {rec_data[2]} {rec_data[3]} {rec_data[4]} {rec_data[5]} {rec_data[6]} {rec_data[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {tx_data[0]} {tx_data[1]} {tx_data[2]} {tx_data[3]} {tx_data[4]} {tx_data[5]} {tx_data[6]} {tx_data[7]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_IBUF_BUFG]
