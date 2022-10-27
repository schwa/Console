import Console
import SwiftUI

@main
struct DemoApp: App {

    @Environment(\.openWindow)
    var openWindow

    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        Window("Console", id: "console") {
            ConsoleView()
        }
        .commands {
            CommandMenu("Debug") {
                Button("Show Console") {
                    openWindow(id: "console")
                }
                .keyboardShortcut(.init("1", modifiers: .command))
            }
        }

    }
}
