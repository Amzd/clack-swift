# Clack

A description of this package.

```swift
intro(title: "Settings")

let output = text(question: "Question example", placeholder: "example", validator: { $0 == "hi" ? .success("") : .failure("fill in hi") })

_ = select(title: "Picker", options: [
    ("a", value: 1),
    ("b", value: 1),
    ("c", value: 1),
    ("d", value: 1),
])

outro(text: "Problems? " + "https://github.com/Amzd/clack-swift/issues".bold.foreColor(81))
```
