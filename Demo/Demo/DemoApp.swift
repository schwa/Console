import Console
import SwiftUI

@main
struct DemoApp: App {

    @Environment(\.openWindow)
    var openWindow

    var body: some Scene {
        Window("Demo", id: "demo") {
            ContentView()
        }
        .commands {
            CommandMenu("Debug") {
                Button("Show Demo") {
                    openWindow(id: "demo")
                }
                .keyboardShortcut(.init("1", modifiers: .command))
            }
        }
        Window("Console", id: "console") {
            ConsoleView()
            .onOpenURL { url in
                print("RECEIVED \(url)")
            }
        }
        .commands {
            CommandMenu("Debug") {
                Button("Show Console") {
                    openWindow(id: "console")
                }
                .keyboardShortcut(.init("I", modifiers: .command))
            }
        }
    }
}
