# SC-OBC-A1 FPGA System Driver for OpenOCD
# ----------------------------------------

# Register Map
set sysreg_codemsel       0x0000
set sysreg_sysclkctl      0x0004
set sysreg_cfgmemctl      0x0010
set sysreg_pwrcycle       0x0020
set sysreg_pwrmanage      0x0030
set sysreg_spad1          0x00F0
set sysreg_spad2          0x00F4
set sysreg_spad3          0x00F8
set sysreg_spad4          0x00FC
set sysreg_ver            0xF000
set sysreg_buildinfo      0xFF00
set sysreg_dna1           0xFF10
set sysreg_dna2           0xFF14

source driver/driver-base.tcl

proc get_build_info { } {
    global sysreg_base
    global sysreg_buildinfo

    set data [peak32 [expr $sysreg_base | $sysreg_buildinfo]]
    puts "Build Infomation : $data"
}

proc get_dna { } {
    global sysreg_base
    global sysreg_dna1
    global sysreg_dna2

    set data [expr [peak32 [expr $sysreg_base | $sysreg_dna2]] << 32]
    set data [expr $data | [peak32 [expr $sysreg_base | $sysreg_dna1]]]

    puts [format "FPGA DNA         : 0x%x" $data]
}

proc write_spad { reg data } {
    global sysreg_base
    global sysreg_spad1

    if { $reg > 4 || $reg <= 0 } {
        return
    }

    mww [expr $sysreg_base | ($sysreg_spad1 + (0x4 * [expr $reg -1]))] $data
    puts "Write Scratchpad${reg}: $data"
}

proc read_spad { reg } {
    global sysreg_base
    global sysreg_spad1

    if { $reg > 4 || $reg <= 0 } {
        return
    }

    set data [peak32 [expr $sysreg_base | ($sysreg_spad1 + (0x4 * [expr $reg -1]))]]
    puts "Read Scratchpad${reg} : $data"
}
