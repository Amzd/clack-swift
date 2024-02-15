import ANSITerminal

public func outro(text: String) {
    cursorOff()
    write("\n" + ANSIChar.closer + " " + text)
    write("\n")
    cursorOn()
}
