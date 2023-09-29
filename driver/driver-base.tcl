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
