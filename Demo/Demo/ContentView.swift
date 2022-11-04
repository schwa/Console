import Console
import SwiftUI
import Extendable
import ExtendableViews

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
            Button("Random Value") {
                console(value: Int.random(in: 0...20), for: "Key 1")
//                DispatchQueue.main.async {
//                    print(Console.shared.records)
//                }
            }

            Button("10 x Random Keys and Values") {
                let count = 10
                for _ in 0..<10 {
                    console(value: "Value \(Int.random(in: 0...20))", for: "Key \(Int.random(in: 0...20))")
                }
            }
            Button("Color.red") {
                console(value: Color.red, for: "color")
            }
            Button("Random Color") {
                console(value: Color(hue: .random(in: 0...1), saturation: .random(in: 0...1), brightness: .random(in: 0...1)), for: "color")
            }
            HStack {
                TextField("Key", text: $key).onSubmit(post)
                TextField("Value", text: $value).onSubmit(post)
                Button("Post", action: post)
                    .disabled(key.isEmpty)
            }

            AppExtensionBrowserView().border(Color.red)
        }
        .padding()
        .registerConsoleView(type: Color.self) { color in
            color.frame(width: 16, height: 16)
                //.contextMenu(forSelectionType: Color.self, menu: { _ in }, primaryAction: { _ in })
                .contextMenu {
                    Button("Copy") {

                    }
                }
                .help("SwiftUI.Color \(color.description)")
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
