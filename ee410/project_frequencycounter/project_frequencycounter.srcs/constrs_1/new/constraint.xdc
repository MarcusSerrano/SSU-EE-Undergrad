## External pins only (internal clock = no create_clock here)

## RPIO26 (pin 37) -> W9 : OUTPUT (test square wave)
set_property PACKAGE_PIN W9  [get_ports { rpio26_out }]
set_property IOSTANDARD LVCMOS33 [get_ports { rpio26_out }]

## RPIO20 (pin 38) -> A20 : INPUT (sense / measured)
set_property PACKAGE_PIN A20 [get_ports { rpio20_in }]
set_property IOSTANDARD LVCMOS33 [get_ports { rpio20_in }]
# Optional input pull-up:
# set_property PULLUP true [get_ports { rpio20_in }]

## RESET on RPIO02 (pin 3) -> W18 : ACTIVE-LOW with PULLUP
## Leave floating to run; short W18 to GND to reset.
set_property PACKAGE_PIN W18 [get_ports { rst_n }]
set_property IOSTANDARD LVCMOS33 [get_ports { rst_n }]
set_property PULLUP true [get_ports { rst_n }]
