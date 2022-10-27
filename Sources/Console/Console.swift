import simd
import SwiftUI

public class Console: ObservableObject {

    public struct Record {
        public var date: Date = Date()
        public var key: String
        public var value: Any
        public var historyValues: [(Date, Any)] = []
        public var updateCount: Int = 0
        public var repeatCount: Int = 0
        public var formatter: Optional<(Any) -> AnyView> = nil
    }


    public static let shared = Console()

    @Published
    public private(set) var records: [String: Record] = [:]

    public private(set) var formatters: [AnyHashable: (Any) -> AnyView] = [:]

    public init() {
        registerDefaultFormatters()
    }

    public func post(value: Any, for key: String) {
        DispatchQueue.main.async { [weak self] in
            self?.post_(value: value, for: key)
        }
    }

    private func post_(value: Any, for key: String) {
        var record = records[key, default: Record(key: key, value: value)]
        if let oldValue = records[key]?.value, oldValue as? AnyHashable == record.value as? AnyHashable {
            record.repeatCount += 1
        }

        record.updateCount += 1
        records[key] = record
    }
}

// MARK: -

public extension Console {
    func register<T>(type: T.Type, view: @escaping (T) -> some View) {
        formatters[ObjectIdentifier(type)] = { value in
            // swiftlint:disable:next force_cast
            let value = value as! T
            return AnyView(view(value))
        }
    }

    func register<F>(type: F.FormatInput.Type, format: F) where F : FormatStyle, F.FormatInput : Equatable, F.FormatOutput == String {
        register(type: type) { value in
            Text(value, format: format)
        }
    }

    func registerDefaultFormatters() {
        register(type: Float.self, format: .number)
        register(type: String.self) { value in
            Text(verbatim: value)
        }
    }
}

// MARK: -

public func console(value: Any, for key: String) {
    Console.shared.post(value: value, for: key)
}

// MARK: -

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
