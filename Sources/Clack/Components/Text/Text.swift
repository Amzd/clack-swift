import ANSITerminal

func writeAt(_ row: Int, _ col: Int, _ text: String) {
    moveTo(row, col)
    write(text)
}

public func text(question: String, isSecureEntry: Bool = false) -> String {
    cursorOn()
    moveLineDown()
    let promptStartLine = readCursorPos().row
    write("◆".foreColor(81).bold)
    moveRight()
    write(question)
    moveLineDown()
    write(ANSIChar.activeBracketLine)
    moveLineDown()
    write(ANSIChar.activeCloser)
    
    let bottomPos = readCursorPos()
    moveLineUp()
    moveRight(2)
    
    let textInput = readTextInput(
        onNewCharacter: { char in write("\(isSecureEntry ? "▪" : char)") },
        onDelete: { row, col in moveTo(row, col); deleteChar() }
)
    
    cleanUp(startLine: promptStartLine, endLine: bottomPos.row)
    
    return textInput
}



func cleanUp(startLine: Int, endLine: Int) {
    cursorOff()
    
    writeAt(startLine, 0, "✔".green)
    (startLine + 1...endLine).forEach { writeAt($0, 0, ANSIChar.bracketLine) }
    
    moveTo(endLine, 0)
    
    cursorOn()
}