import ANSITerminal

func writeAt(_ row: Int, _ col: Int, _ text: String) {
    moveTo(row, col)
    write(text)
}

/// An error type that is presented to the user as an error with parsing their
/// command-line input.
public struct ValidatorError: Error, CustomStringConvertible {
  /// The error message represented by this instance, this string is presented to
  /// the user when a `ValidationError` is thrown from either; `run()`,
  /// `validate()` or a transform closure.
  public internal(set) var message: String

  /// Creates a new validation error with the given message.
  public init(_ message: String) {
    self.message = message
  }

  public var description: String {
    message
  }
}

extension Result where Failure == ValidatorError {
    /// Allows initialising with just a string so you can do
    /// `Result.failure("message")` instead of `.failure(.message("message"))`
    public static func failure(_ message: String) -> Self {
        .failure(.init(message))
    }
}

public typealias Validator<T> = (String) -> Result<T, ValidatorError>

public func text(question: String, placeholder: String = "", isSecureEntry: Bool = false) -> String {
    text(question: question, placeholder: placeholder, validator: { .success($0) }, isSecureEntry: isSecureEntry)
}

public func text<T: LosslessStringConvertible>(question: String, placeholder: String = "", isSecureEntry: Bool = false) -> T {
    text(question: question, placeholder: placeholder, validator: {
        guard let value = T($0) else {
            return .failure("You must enter a valid \(T.self)")
        }
        return .success(value)
    }, isSecureEntry: isSecureEntry)
}

public func text<T>(question: String, placeholder: String = "", validator: Validator<T>, isSecureEntry: Bool = false) -> T {
    precondition(!question.contains("\n"))
    precondition(!placeholder.contains("\n"))

    cursorOn()
    write("\n" + ANSIChar.info + " " + question)
    write("\n" + ANSIChar.activeBracketLine)
    write("\n" + ANSIChar.activeCloser)

    // get pos after writing newlines because scroll might have happened
    let promptStartLine = readCursorPos().row - 2
    let bottomPos = readCursorPos()
    moveLineUp()
    moveRight(2)
    let initialCursorPosition = readCursorPos()
    write(placeholder.foreColor(244))
    moveTo(initialCursorPosition.row, initialCursorPosition.col)

    var validationFailed = false

    let result = readTextInput(
        validator: validator,
        validationFailed: { failureString in
            validationFailed = true
            cursorOff()
            let currentPosition = readCursorPos()
            writeAt(promptStartLine, 0, ANSIChar.warn)
            updateBracketColor(fromLine: promptStartLine, toLine: bottomPos.row, withColor: 11)
            writeAt(bottomPos.row, bottomPos.col + 1, failureString)
            moveTo(currentPosition.row, currentPosition.col)
            cursorOn()
        },
        onInputChange: { input in
            if validationFailed {
                cursorOff()
                let currentPosition = readCursorPos()
                writeAt(promptStartLine, 0, ANSIChar.info)
                updateBracketColor(fromLine: promptStartLine, toLine: bottomPos.row, withColor: 81)
                moveTo(bottomPos.row, bottomPos.col + 1)
                clearToEndOfLine()
                moveTo(currentPosition.row, currentPosition.col)
                cursorOn()
                validationFailed = false
            }
            let currentPosition = readCursorPos()
            writeAt(currentPosition.row, 3, input.isEmpty
                ? placeholder.foreColor(244)
                : isSecureEntry ? String(repeating: "▪", count: input.count) : input)
            clearToEndOfLine()
            moveToColumn(3 + input.count)
        }
    )

    cleanUp(startLine: promptStartLine, endLine: bottomPos.row)

    return result
}

func updateBracketColor(fromLine: Int, toLine: Int, withColor color: UInt8) {
    (fromLine + 1...toLine - 1).forEach { writeAt($0, 0, ANSIChar.bracketLineNoColour.foreColor(color)) }
    writeAt(toLine, 0, ANSIChar.closerNoColour.foreColor(color))
}

func cleanUp(startLine: Int, endLine: Int) {
    cursorOff()

    writeAt(startLine, 0, ANSIChar.success)
    (startLine + 1...endLine).forEach { writeAt($0, 0, ANSIChar.bracketLine) }

    moveTo(endLine, 0)

    cursorOn()
}
