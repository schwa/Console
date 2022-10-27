import SwiftUI
import Everything

public struct ConsoleView: View {
    @StateObject
    var console = Console.shared

    @State
    var pinnedKeys: Set<String> = []

    public init() {
    }

    public var body: some View {
        List {
            if !pinnedKeys.isEmpty {
                Section("Pinned") {
                    let keys = Array(pinnedKeys.sorted())
                    ForEach(keys, id: \.self) { key in
                        let record = console.records[key]!
                        row(for: record)
                    }
                }
            }
            let items = Array(console.records.filter({ !pinnedKeys.contains($0.key)}).sorted(by: { $0.key < $1.key }))
            if !items.isEmpty {
                Section("Records") {
                    ForEach(items, id: \.key) { key, record in
                        row(for: record)
                    }
                }
            }
        }
        .listStyle(.bordered(alternatesRowBackgrounds: true))
    }

    @ViewBuilder
    func row(for record: Console.Record) -> some View {
        let value = record.value
        let view = console.formatters[ObjectIdentifier(type(of: value))] ?? fallbackFormatter
        LabeledContent(record.key) {
            HStack {
                view(value).id(record.key)
                if record.repeatCount > 0 {
                    Text("repeated \(record.repeatCount) times.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    pinnedKeys.toggle(record.key)
                } label: {
                    if pinnedKeys.contains(record.key) {
                        Image(systemName: "pin.circle.fill").foregroundColor(.accentColor)
                    }
                    else {
                        Image(systemName: "pin.circle")
                    }
                }
                .buttonStyle(.borderless)
            }
        }
        .labeledContentStyle(MyLabeledContentStyle(labelWidth: 60))

    }

    func fallbackFormatter(_ value: Any) -> AnyView {
        AnyView(Text(verbatim: String(describing: value)))
    }
}

struct MyLabeledContentStyle: LabeledContentStyle {

    let labelWidth: CGFloat?

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            .frame(width: labelWidth, alignment: .leading)
//            .border(Color.red)
            configuration.content
//            .border(Color.red)
        }
    }
}
