import SwiftUI
import Everything

public struct ConsoleView: View {
    @StateObject
    var console = Console.shared

    @State
    var pinnedKeys: Set<String> = []

    @State
    var hiddenKeys: Set<String> = []

    @State
    var sortBy: String = "key"

    public init() {
    }

    public var body: some View {
        List {
            let pinnedRecords = records(pinned: true)
            if !pinnedRecords.isEmpty {
                Section("Pinned") {
                    ForEach(pinnedRecords, id: \.key) { record in
                        row(for: record)
                    }
                }
            }

            let unpinnedRecord = records(pinned: false)
            if !unpinnedRecord.isEmpty {
                Section("Records") {
                    ForEach(unpinnedRecord, id: \.key) { record in
                        row(for: record)
                    }
                }
            }
        }
        .listStyle(.bordered(alternatesRowBackgrounds: true))
        .toolbar {
            Button("Clear") {
            }
            Button("Unhide Everything") {
                hiddenKeys = []
            }
            Picker("Sort By", selection: $sortBy) {
                Text("Key").tag("key")
                Text("Updated").tag("updated")
            }
            .toolbarTitleMenu {
                Text("Title")
            }

        }
    }

    func records(pinned: Bool) -> [Console.Record] {
        console.records.values
        .filter { record in
            !hiddenKeys.contains(record.key)
        }
        .filter { record in
            pinnedKeys.contains(record.key) == pinned
        }
        .sorted { lhs, rhs in
            switch sortBy {
            case "key":
                return lhs.key < rhs.key
            case "updated":
                return lhs.date < rhs.date
            default:
                fatalError()

            }


        }
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
        .contextMenu {
            Button(pinnedKeys.contains(record.key) ? "Unpin" : "Pin", action: { pinnedKeys.toggle(record.key)})
            Button("Hide") {
                hiddenKeys.insert(record.key)
            }
        }

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
