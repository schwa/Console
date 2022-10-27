import simd
import SwiftUI

public class Console: ObservableObject {
    public static let shared = Console()

    @Published
    public private(set) var values: [String: Any] = [:]

    public private(set) var formatters: [AnyHashable: (Any) -> AnyView] = [:]

    public init() {
        registerDefaultFormatters()
    }

    public func post(value: Any, for key: String) {
        values[key] = value
    }

    public func register<T>(type: T.Type, view: @escaping (T) -> some View) {
        formatters[ObjectIdentifier(type)] = { value in
            // swiftlint:disable:next force_cast
            let value = value as! T
            return AnyView(view(value))
        }
    }

}

public extension Console {
    func register<F>(type: F.FormatInput.Type, format: F) where F : FormatStyle, F.FormatInput : Equatable, F.FormatOutput == String {
        register(type: type) { value in
            Text(value, format: format)
        }
    }

    func registerDefaultFormatters() {
        register(type: Float.self) { value in
            Text("\(value, format: .number)").monospacedDigit()
        }
    }
}

public func console(value: Any, for key: String) {
    DispatchQueue.main.async {
        Console.shared.post(value: value, for: key)
    }
}

public extension View {
    func registerConsoleView<T>(type: T.Type, view: @escaping (T) -> some View) -> some View {
        Console.shared.register(type: type, view: view)
        return self
    }

    func registerConsoleFormatStyle<F>(type: F.FormatInput.Type, format: F) -> some View where F : FormatStyle, F.FormatInput : Equatable, F.FormatOutput == String {
        Console.shared.register(type: type, format: format)
        return self
    }
}

// MARK: -

public struct ConsoleView: View {
    @StateObject
    var console = Console.shared

    public init() {

    }

    public var body: some View {
        if !console.values.isEmpty {
            let items = Array(console.values.sorted(by: { $0.key < $1.key }))
            List(items, id: \.key) { key, value in
                if let view = console.formatters[ObjectIdentifier(type(of: value))] {
                    HStack(alignment: .top, spacing: 0) {
                        Text("\(key) = ")
                        view(value)
                    }
                } else {
                    Text("\(key) = \(String(describing: value)) \(String(describing: type(of: value)))")
                        .foregroundColor(.red)
                }
            }
        }
    }
}
