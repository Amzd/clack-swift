# Clack

A Swift port of https://github.com/natemoo-re/clack/

```swift
intro(title: "Settings")

let questionResult = text(question: "Question example", placeholder: "example", validator: { $0 == "hi" ? .success("") : .failure("fill in hi") })

let pickerResult = select(title: "Picker", options: [
    ("a", value: 1),
    ("b", value: 1),
    ("c", value: 1),
    ("d", value: 1),
])

outro(text: "Problems? " + "https://github.com/Amzd/clack-swift/issues".bold.foreColor(81))
```
