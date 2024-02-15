import ANSITerminal

public enum ANSIChar {
    static let activeBracketLine = "│".foreColor(81)
    static let bracketLine = "│".foreColor(252)
    static let bracketLineNoColour = "│"
    static let opener = "┌".foreColor(252)
    static let closer = "└".foreColor(252)
    static let closerNoColour = "└"
    static let activeCloser = "└".foreColor(81)

    public static var warn = "▲".yellow
    public static var info = "●".foreColor(81).bold // "◆" is not centered in my font
    public static var success = "✔".green
    public static var selected = "●".lightGreen
    public static var unselected = "○".foreColor(250)
}
