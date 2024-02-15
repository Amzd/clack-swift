import ANSITerminal

/// Adds a closing character to any step to make it standalone.
/// This means you won't need an outro to make eg a picker visually pleasing.
///
///     standalone {
///         select( ... )
///     }
///
public func standalone<T>(_ step: @autoclosure () -> T) -> T {
    moveLineUp()
    let result = step()
    write(ANSIChar.closer + "\n")
    return result
}
