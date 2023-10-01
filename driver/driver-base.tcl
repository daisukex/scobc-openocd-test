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
