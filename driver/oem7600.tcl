# Space Cubics Novatel OEM7600 Driver for OpenOCD
# -----------------------------------------------

source driver/driver-base.tcl
source driver/uart-lite.tcl

proc gnss_get_bestpos_once { gnss } {

    # Send Command
    puts "GNSS Command Send"
    set com "log com1 bestpos once"
    uartl_send_no_display $gnss [str2asc $com]
    uartl_send_no_display $gnss {0x0d}
    puts $com

    # Receive Data
    sleep 1000
    puts ""
    puts "GNSS Data Receive"
    set data [hex2asc [uartl_receive_ret_data $gnss]]
    if {$data != ""} {
        puts $data
    }
}

proc gnss_get_receive_data { gnss } {
    puts "GNSS Data Receive"
    set data [hex2asc [uartl_receive_ret_data $gnss]]
    if {$data != ""} {
        puts $data
    }
}
