import Console
import SwiftUI

struct ContentView: View {

    @State
    var key: String = ""

    @State
    var value: String = ""

    var body: some View {
        List {
            Button("Once") {
                console(value: "Value 1", for: "Key 1")
            }
            Button("10 x Random") {
                let count = 10
                for _ in 0..<10 {
                    console(value: "Value \(Int.random(in: 0...20))", for: "Key \(Int.random(in: 0...20))")
                }
            }
            Button("Color") {
                console(value: Color.red, for: "color")
            }
            HStack {
                TextField("Key", text: $key).onSubmit(post)
                TextField("Value", text: $value).onSubmit(post)
                Button("Post", action: post)
                    .disabled(key.isEmpty)
            }
        }
        .padding()
        .registerConsoleView(type: Color.self) { color in
            color.frame(width: 16, height: 16)
        }
    }

    func post() {
        key = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else {
            return
        }
        console(value: value, for: key)
    }
}
