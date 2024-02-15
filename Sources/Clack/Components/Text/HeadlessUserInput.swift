import Foundation
import ANSITerminal

// TODO: handle input wider than terminal window (rn it overlaps onto next row)

func readTextInput<T>(
    validator: Validator<T>,
    validationFailed: (String) -> Void,
    onInputChange: (String) -> Void
) -> T {
    var input = ""
    let start = readCursorPos().col

    whileloop: while true {
        clearBuffer()

        if keyPressed() {
            let char = readChar()
            if char == NonPrintableChar.enter.char() {
                switch validator(input) {
                case .success(let value):
                    return value
                case .failure(let error):
                    validationFailed(error.message)
                }
            } else if char == NonPrintableChar.del.char() {
                let cursorPosition = readCursorPos()
                if input.count > 0 && cursorPosition.col > start {
                    let index = input.index(input.startIndex, offsetBy: cursorPosition.col - 1 - start)
                    _ = input.remove(at: index)
                    onInputChange(input)
                    moveToColumn(cursorPosition.col - 1)
                }
            } else if "\(char)" == ESC {
                var code = ESC
                code.append(readChar())
                switch code {
                case CSI:
                    switch readChar() {
                    case "C" where readCursorPos().col - start < input.count:
                        moveRight()
                    case "D" where readCursorPos().col - start > 0:
                        moveLeft()
                    default: break
                    }
                    continue whileloop
                default: break
                }
            }

            if !isNonPrintable(char: char) {
                let pos = readCursorPos().col
                let index = input.index(input.startIndex, offsetBy: pos - start)
                input.insert(char, at: index)
                onInputChange(input)
            }
        }
    }
}
