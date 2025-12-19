## Pynq-Z2 constraints for XADC temperature + PmodSSD demo

## 125 MHz PL clock (from Ethernet PHY) on pin H16
set_property PACKAGE_PIN H16 [get_ports clk_125mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_125mhz]
create_clock -period 8.000 -name sys_clk [get_ports clk_125mhz]

## BTN0 as active-high reset input
set_property PACKAGE_PIN D19 [get_ports btn_reset]
set_property IOSTANDARD LVCMOS33 [get_ports btn_reset]

## User LEDs (LED0..LED3)
set_property PACKAGE_PIN R14 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

set_property PACKAGE_PIN P14 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

set_property PACKAGE_PIN N16 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

set_property PACKAGE_PIN M14 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

## Pmod A (JA) top row pins -> PmodSSD J1 segments A..D
## JA pin1 (Y18) -> ja[0] -> segment A (AA)
set_property PACKAGE_PIN Y18 [get_ports {ja[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ja[0]}]

## JA pin2 (Y19) -> ja[1] -> segment B (AB)
set_property PACKAGE_PIN Y19 [get_ports {ja[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ja[1]}]

## JA pin3 (Y16) -> ja[2] -> segment C (AC)
set_property PACKAGE_PIN Y16 [get_ports {ja[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ja[2]}]

## JA pin4 (Y17) -> ja[3] -> segment D (AD)
set_property PACKAGE_PIN Y17 [get_ports {ja[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ja[3]}]

## Pmod B (JB) top row pins -> PmodSSD J2 segments E,F,G + digit select C
## JB pin1 (W14) -> jb[0] -> segment E (AE)
set_property PACKAGE_PIN W14 [get_ports {jb[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {jb[0]}]

## JB pin2 (Y14) -> jb[1] -> segment F (AF)
set_property PACKAGE_PIN Y14 [get_ports {jb[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {jb[1]}]

## JB pin3 (T11) -> jb[2] -> segment G (AG)
set_property PACKAGE_PIN T11 [get_ports {jb[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {jb[2]}]

## JB pin4 (T10) -> jb[3] -> digit select C
set_property PACKAGE_PIN T10 [get_ports {jb[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {jb[3]}]

## PmodSSD J1/J2 pins 5 and 6 connect to the board's GND and 3.3V rails automatically
## when the modules are plugged into Pmod A and Pmod B, so no constraints are needed.
