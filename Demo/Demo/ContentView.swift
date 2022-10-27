import Console
import SwiftUI

struct ContentView: View {

    @State
    var key: String = ""

    @State
    var value: String = ""

    var body: some View {
        HStack {
            TextField("Key", text: $key).onSubmit(post)
            TextField("Value", text: $value).onSubmit(post)
            Button("Post", action: post)
            .disabled(key.isEmpty)
        }
        .padding()
    }

    func post() {
        key = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else {
            return
        }
        console(value: value, for: key)
    }
}
