# Space Cubics Uart-Lite Driver for OpenOCD
# -----------------------------------------

# Register Map
set uartl_rxfifor         0x0000
set uartl_txfifor         0x0004
set uartl_statr           0x0008
set uartl_ctrlr           0x000C
set uartl_ubrsr           0x0010
set uartl_ver             0xF000

source driver/driver-base.tcl

proc __chk_txfifo_full { base } {
    global uartl_statr
    set fullbit 0x08

    return [expr [peak08 [expr $base | $uartl_statr]] & $fullbit]
}

proc __chk_rxfifo_notempty { base } {
    global uartl_statr
    set empbit 0x01

    return [expr [peak08 [expr $base | $uartl_statr]] & $empbit]
}

proc uart_init { base sysclk bardrate } {
    global uartl_ver
    set data [peak32 [expr $base | $uartl_ver]]
    puts "Space Cubics UART-Lite (sc-uartlit)"
    puts " Version: $data"
    set_baudrate $base $sysclk $bardrate
}

proc set_baudrate { base sysclk baudrate } {
    global uartl_ubrsr

    set freqs [expr ($sysclk * 1000000) / $baudrate]
    set data [expr round($freqs) - 1]
    mww [expr $base | $uartl_ubrsr] $data
    puts "UART-Lite"
    puts [format "Set Boardrate : $baudrate (0x%x)" $data]
}

proc send_uart { base text } {
    global uartl_txfifor

    set byte [llength $text]
    for {set i 0} {$i < $byte} {incr i} {
        while { [__chk_txfifo_full $base] } {}
        mww [expr $base | $uartl_txfifor] [lindex $text $i]
    }
    puts "UART Send Data   : $text"
}

proc receive_uart { base } {
    global uartl_rxfifor

    while { [__chk_rxfifo_notempty $base] } {
        lappend data [peak08 [expr $base | $uartl_rxfifor]]
    }
    puts "UART Receive Data: $data"
}

proc get_uart_status { base } {
    global uartl_statr

    set status [peak32 [expr $base | $uartl_statr]]
    puts "UART Lite Status : $status"
}