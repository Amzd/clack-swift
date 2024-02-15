import ANSITerminal

public func intro(title: String, clear: Bool = false) {
    if clear {
        clearScreen()
    }
    write(ANSIChar.opener + " " + " \(title) ".black.backColor(81))
    write("\n" + ANSIChar.bracketLine)
}
