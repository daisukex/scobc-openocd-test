# Space Cubics ADCS System Register Driver for OpenOCD
# ----------------------------------------------------

# Register Map
set adcs_pcr              0x0000
set adcs_ircr             0x0004
set adcs_mdcr             0x0008
set adcs_imuisr           0x0010
set adcs_imuier           0x0014
set adcs_drvisr           0x0020
set adcs_drvier           0x0024

source driver/driver-base.tcl

proc rtn_apc { } {
    global adcs_sysreg_base
    global adcs_pcr
    return [peak08 [expr $adcs_sysreg_base | $adcs_pcr]]
}

proc set_apc { data } {
    global adcs_sysreg_base
    global adcs_pcr
    mww [expr $adcs_sysreg_base | $adcs_pcr] [expr 0x5A5A0000 | $data]
}

proc set_power_ctrl { data } {
    global adcs_sysreg_base
    global adcs_pcr
    set_apc $data
    display_adcs_power 7
}

proc get_power_ctrl { } {
    display_adcs_power 7
}

proc display_adcs_power { flag } {
    global adcs_sysreg_base
    global adcs_pcr

    set data [peak08 [expr $adcs_sysreg_base | $adcs_pcr]]

    puts "ADCS Power"
    if { [expr $flag & 0x1] } {
        if { [expr $data & 0x1] } {
            puts " IMU Power: ON"
        } else {
            puts " IMU Power: OFF"
        }
    }

    if { [expr $flag & 0x2] } {
        if { [expr $data & 0x2] } {
            puts " GPS Power: ON"
        } else {
            puts " GPS Power: OFF"
        }
    }

    if { [expr $flag & 0x4] } {
        if { [expr $data & 0x4] } {
            puts " DRV Power: ON"
        } else {
            puts " DRV Power: OFF"
        }
    }
}

proc imu_power_on { } {
    set imu_bit 0x1
    set data [rtn_apc]

    set_apc [expr $data | $imu_bit]
    display_adcs_power 1
}

proc imu_power_off { } {
    set imu_bit 0x6
    set data [rtn_apc]

    set_apc [expr $data & $imu_bit]
    display_adcs_power 1
}

proc gps_power_on { } {
    set gps_bit 0x2
    set data [rtn_apc]

    set_apc [expr $data | $gps_bit]
    display_adcs_power 2
}

proc gps_power_off { } {
    set gps_bit 0x5
    set data [rtn_apc]

    set_apc [expr $data & $gps_bit]
    display_adcs_power 2
}

proc drv_power_on { } {
    set drv_bit 0x4
    set data [rtn_apc]

    set_apc [expr $data | $drv_bit]
    display_adcs_power 4
}

proc drv_power_off { } {
    set drv_bit 0x3
    set data [rtn_apc]

    set_apc [expr $data & $drv_bit]
    display_adcs_power 4
}
