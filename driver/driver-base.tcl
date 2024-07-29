proc peak08 { addr } {
    set val [mdb $addr]
    set v [lindex [split $val ": "] 2]
    return 0x$v
}

proc peak16 { addr } {
    set val [mdh $addr]
    set v [lindex [split $val ": "] 2]
    return 0x$v
}

proc peak32 { addr } {
    set val [mdw $addr]
    set v [lindex [split $val ": "] 2]
    return 0x$v
}

proc splitdata { data byte } {
    return [expr ($data >> ($byte * 8)) & 0xFF]
}

proc str2asc { str } {
    set len [string length $str]
    for {set i 0} {$i < $len} {incr i} {
        scan [string range $str $i $i] "%c" asc
        lappend data [format "0x%x" $asc]
    }
    return $data
}

proc hex2asc { hex } {
    set len [llength $hex]
    set data ""
    if { $len > 0 } {
        for {set i 0} {$i < $len} {incr i} {
            set char [lindex $hex $i]
            append data [format "%c" $char]
        }
        return $data
    }
    return ""
}

proc __access_type { width } {
    if { $width == 32 } {
        return "WORD"
    } else if { $width == 16 } {
        return "HWORD"
    } else if { $width == 8 } {
        return "BYTE"
    } else {
        return ""
    }
}

proc poke { addr width data } {
    global regdebug
    if {$regdebug == 1} {
        puts [format "WR %-5s %#08x %#08x" [__access_type $width] $addr $data]
    }
    write_memory $addr $width $data
}

proc peak { addr width } {
    global regdebug
    set rd [read_memory $addr $width 1]
    if {$regdebug == 1} {
        puts [format "RD %-5s %#08x %#08x" [__access_type $width] $addr $rd ]
    }
    return $rd
}
