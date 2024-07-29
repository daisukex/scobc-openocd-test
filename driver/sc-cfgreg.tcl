# Space Cubics Configuration Register Driver for OpenOCD
# ------------------------------------------------------

# Register Map
set cfgrver   0x0000
set cfgradr   0x0004
set  regadr        0
set cfgrdat   0x0008
set cfgrclk   0x000C
set  keycode      16
set  clkdiv        0

set magiccode 0x5A5A
set idcode      0x0C
set bootsts     0x16

source driver/driver-base.tcl


proc disp_cfgreg_var { } {
    global cfgreg_base
    global cfgrver

    set ver [peak [expr {$cfgreg_base | $cfgrver}] 32]
    puts [format "Configuration Register Module Version: %#08x" $ver]
}

proc set_icap_clk { value } {
    global cfgreg_base
    global cfgrclk
    global keycode
    global cfgradr
    global regadr
    global magiccode
    global idcode
    if {$value == "on"} {
        poke [expr {$cfgreg_base | $cfgrclk}] 32 [expr {$magiccode << $keycode}]
        puts "Start ICAPE2 clock"
        # Dummy read
        poke [expr {$cfgreg_base | $cfgradr}] 32 [expr {$idcode << $regadr}]
    } else {
        poke [expr {$cfgreg_base | $cfgrclk}] 32 [expr {(~ $magiccode) << $keycode}]
        puts "Stop ICAPE2 clock"
    }
}

proc disp_idcode { } {
    global cfgreg_base
    global cfgradr
    global cfgrdat
    global regadr
    global idcode

    poke [expr {$cfgreg_base | $cfgradr}] 32 [expr {$idcode << $regadr}]
    set reg [peak [expr {$cfgreg_base | $cfgrdat}] 32]
    puts [format "Configuration Register: IDCODE %#08x" $reg]
}

proc disp_bootsts { } {
    global cfgreg_base
    global cfgradr
    global cfgrdat
    global regadr
    global bootsts

    poke [expr {$cfgreg_base | $cfgradr}] 32 [expr {$bootsts << $regadr}]
    set reg [peak [expr {$cfgreg_base | $cfgrdat}] 32]

    puts [format "Configuration Register: BOOT_STATUS %#08x" $reg]
    puts [format " Bit 00_0: STATUS_VALID           %b" [expr { $reg        & 0x1}]]
    puts [format " Bit 01_0: FALLBACK               %b" [expr {($reg >> 1)  & 0x1}]]
    puts [format " Bit 02_0: INTERNAL_PROG          %b" [expr {($reg >> 2)  & 0x1}]]
    puts [format " Bit 03_0: WATCHDOG_TIMEOUT_ERROR %b" [expr {($reg >> 3)  & 0x1}]]
    puts [format " Bit 04_0: ID_ERROR               %b" [expr {($reg >> 4)  & 0x1}]]
    puts [format " Bit 05_0: CRC_ERROR              %b" [expr {($reg >> 5)  & 0x1}]]
    puts [format " Bit 06_0: WRAP_ERROR             %b" [expr {($reg >> 6)  & 0x1}]]

    puts [format " Bit 00_1: STATUS_VALID           %b" [expr {($reg >> 8)  & 0x1}]]
    puts [format " Bit 01_1: FALLBACK               %b" [expr {($reg >> 9)  & 0x1}]]
    puts [format " Bit 02_1: INTERNAL_PROG          %b" [expr {($reg >> 10) & 0x1}]]
    puts [format " Bit 03_1: WATCHDOG_TIMEOUT_ERROR %b" [expr {($reg >> 11) & 0x1}]]
    puts [format " Bit 04_1: ID_ERROR               %b" [expr {($reg >> 12) & 0x1}]]
    puts [format " Bit 05_1: CRC_ERROR              %b" [expr {($reg >> 13) & 0x1}]]
    puts [format " Bit 06_1: WRAP_ERROR             %b" [expr {($reg >> 14) & 0x1}]]
}
