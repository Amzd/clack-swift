import ANSITerminal

public typealias Selectable<T> = (title: String, value: T)

public func select<Type>(title: String, options: [Selectable<Type>]) -> Type {
    cursorOff()
    write("\n" + ANSIChar.info + " " + title)

    var firstOption = readCursorPos().row + 1
    let state = OptionState(
        options: options.enumerated().map { Option(title: $1.title, value: $1.value, line: firstOption + $0) },
        activeLine: firstOption,
        rangeOfLines: (firstOption, firstOption + options.count - 1)
    )

    options.forEach { selectable in
        let isActive = readCursorPos().row + 1 == state.activeLine
        let indicator = isActive ? ANSIChar.selected : ANSIChar.unselected
        let title = isActive ? selectable.title : selectable.title.foreColor(250)
        write("\n\(ANSIChar.activeBracketLine) \(indicator) \(title)")
    }

    write("\n" + ANSIChar.activeCloser)
    let bottomLine = readCursorPos().row

    let reRender = {
        (state.rangeOfLines.minimum...state.rangeOfLines.maximum).forEach { line in
            let isActive = line == state.activeLine
            // Update state indicator colour
            let stateIndicator = isActive ? ANSIChar.selected : ANSIChar.unselected
            writeAt(line, 3, stateIndicator)

            // Update picker option title...
            if let title = state.options.first(where: { $0.line == line })?.title {
                let title = isActive ? title : title.foreColor(250)
                writeAt(line, 5, title)
            }
        }
    }

    // need to reRender right away because new lines might have moved everything up
    firstOption = readCursorPos().row - options.count
    state.activeLine = firstOption
    state.rangeOfLines = (firstOption, firstOption + options.count - 1)
    reRender()

    while true {
        clearBuffer()

        if keyPressed() {
            let char = readChar()
            if char == NonPrintableChar.enter.char() {
                break
            }

            let key = readKey()
            if key.code == .up {
                if state.activeLine > state.rangeOfLines.minimum {
                    state.activeLine -= 1

                    reRender()
                }
            } else if key.code == .down {
                if state.activeLine < state.rangeOfLines.maximum {
                    state.activeLine += 1

                    reRender()
                }
            }
        }
    }

    cleanUp(startLine: firstOption - 1, endLine: bottomLine)

    return options[state.activeLine - firstOption].value
}
