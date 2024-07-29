# Space Cubics I2C Master Driver for OpenOCD
# ------------------------------------------

# Register Map
set i2cm_enr              0x0000
set i2cm_txfifor          0x0004
set i2cm_rxfifor          0x0008
set i2cm_bsr              0x000C
set i2cm_isr              0x0010
set i2cm_ier              0x0014
set i2cm_fifosr           0x0018
set i2cm_fiforr           0x001C
set i2cm_ftlsr            0x0020
set i2cm_scltsr           0x0024
set i2cm_thdstar          0x0030
set i2cm_tsustor          0x0034
set i2cm_tsustar          0x0038
set i2cm_thighr           0x003C
set i2cm_thddatr          0x0040
set i2cm_tsudatr          0x0044
set i2cm_tbufr            0x0048
set i2cm_tbsmplr          0x004C
set i2cm_ver              0xF000

source driver/driver-base.tcl

proc i2c_enable { base } {
    global i2cm_enr
    global debug
    mww [expr {$base | $i2cm_enr}] 1
    if {$debug} {
        puts "I2C Master Enable: [peak32 [expr $base | $i2cm_enr]]"
    }
}

proc i2c_disable { base } {
    global i2cm_enr
    global debug
    mww [expr {$base | $i2cm_enr}] 0
    if {$debug} {
        puts "I2C Master Enable: [peak32 [expr $base | $i2cm_enr]]"
    }
}

proc set_i2c_format_100kbps { base } {
    global i2cm_thdstar
    global i2cm_tsustor
    global i2cm_tsustar
    global i2cm_thighr
    global i2cm_thddatr
    global i2cm_tsudatr
    global i2cm_tbufr

    mww [expr {$base | $i2cm_thdstar}] 0x00EF
    mww [expr {$base | $i2cm_tsustor}] 0x00EF
    mww [expr {$base | $i2cm_tsustar}] 0x0117
    mww [expr {$base | $i2cm_thighr}]  0x00E5
    mww [expr {$base | $i2cm_thddatr}] 0x0013
    mww [expr {$base | $i2cm_tsudatr}] 0x00E5
    mww [expr {$base | $i2cm_tbufr}]   0x0117
}

proc i2c_init { base } {
    set_i2c_format_100kbps $base
    i2c_enable $base
}

proc i2c_read { base i2c_addr reg_addr byte} {
    global i2cm_txfifor
    global i2cm_rxfifor
    set b_restart  0x200
    set b_stop     0x100
    set b_read       0x1
    set data         0x0

    set byte [expr {$byte - 1}]
    mww [expr {$base | $i2cm_txfifor}] [expr {$i2c_addr << 1}]
    mww [expr {$base | $i2cm_txfifor}] [expr {$b_restart | $reg_addr}]
    mww [expr {$base | $i2cm_txfifor}] [expr {($i2c_addr << 1) | $b_read}]
    mww [expr {$base | $i2cm_txfifor}] [expr {$b_stop | $byte}]
    for {set i $byte } {$i >= 0} {incr i -1} {
        set data [expr {$data | ([peak08 [expr {$base | $i2cm_rxfifor}]] << ($i * 8))}]
    }
    puts [format "I2C Read Data : 0x%x" $data ]
}

proc i2c_write  { base i2c_addr reg_addr byte data } {
    global i2cm_txfifor
    global i2cm_rxfifor
    set b_restart  0x200
    set b_stop     0x100
    set b_read       0x1
    set byte1          0
    set byte0          0

    mww [expr {$base | $i2cm_txfifor}] [expr {$i2c_addr << 1}]
    mww [expr {$base | $i2cm_txfifor}] [expr {$reg_addr}]

    set byte [expr {$byte - 1}]
    if { $byte > 0 } {
        for {set i $byte} {$i > 0} {incr i -1} {
            mww [expr {$base | $i2cm_txfifor}] [splitdata $data $i]
        }
    }
    mww [expr {$base | $i2cm_txfifor}] [expr {$b_stop | [splitdata $data 0]}]
    puts "I2C Write Data: $data"
}
