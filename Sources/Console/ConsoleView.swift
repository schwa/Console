import SwiftUI
import Everything
import Charts

class Model: ObservableObject {
    @Published
    var pinnedKeys: Set<String> = []

    @Published
    var hiddenKeys: Set<String> = []
}


public struct ConsoleView: View {

    @StateObject
    var model = Model()

    @StateObject
    var console = Console.shared

    enum SortOrder {
        case key
        case updated
    }

    @State
    var sortBy: SortOrder = .key

    public init() {
    }

    public var body: some View {
        List {
            let pinnedRecords = records(pinned: true)
            if !pinnedRecords.isEmpty {
                Section("Pinned") {
                    ForEach(pinnedRecords, id: \.key) { record in
                        RecordRow(record: record)
                    }
                }
            }

            let unpinnedRecord = records(pinned: false)
            if !unpinnedRecord.isEmpty {
                Section("Records") {
                    ForEach(unpinnedRecord, id: \.key) { record in
                        RecordRow(record: record)
                    }
                }
            }
        }
        .environmentObject(model)
#if os(macOS)
        .listStyle(.bordered(alternatesRowBackgrounds: true))
#endif
        .toolbar {
            Button("Clear") {
            }
            .controlSize(.small)

            Button("Unhide Everything") {
                model.hiddenKeys = []
            }
            .controlSize(.small)
            .disabled(model.hiddenKeys.isEmpty)

            Picker("Sort By", selection: $sortBy) {
                Text("Key").tag(SortOrder.key)
                Text("Updated").tag(SortOrder.updated)
            }
            .toolbarTitleMenu {
                Text("Title")
            }
            .controlSize(.small)
        }
    }

    func records(pinned: Bool) -> [Console.Record] {
        console.records.values
            .filter { record in
                !model.hiddenKeys.contains(record.key)
            }
            .filter { record in
                model.pinnedKeys.contains(record.key) == pinned
            }
            .sorted { lhs, rhs in
                switch sortBy {
                case .key:
                    return lhs.key < rhs.key
                case .updated:
                    return lhs.date < rhs.date
                }
            }
    }

    func fallbackFormatter(_ value: Any) -> AnyView {
        AnyView(Text(verbatim: String(describing: value)))
    }
}

struct RecordRow: View {
    let record: Console.Record

    @StateObject
    var console = Console.shared

    @EnvironmentObject
    var model: Model

    @State
    var isPresentingHistoryChart = false

    var body: some View {
        let value = record.value
        let view = console.formatters[ObjectIdentifier(type(of: value))] ?? fallbackFormatter

        LabeledContent {
            HStack {
                view(value).id(record.key)
                if record.repeatCount > 0 {
                    Text("repeated \(record.repeatCount) times.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                Spacer()

                HStack {
                    if console.captureHistoryValuesForKeys.contains(record.key) {
                        Button(systemImage: "chart.xyaxis.line") {
                            isPresentingHistoryChart.toggle()
                        }
                        .popover(isPresented: $isPresentingHistoryChart) {
                            HistoryValueChartView(record: record)
                        }
                    }

                    Button {
                        _ = withAnimation {
                            model.pinnedKeys.toggle(record.key)
                        }
                    } label: {
                        if model.pinnedKeys.contains(record.key) {
                            Image(systemName: "pin.circle.fill").foregroundColor(.accentColor)
                        }
                        else {
                            Image(systemName: "pin.circle")
                        }
                    }
                }
                .buttonStyle(.borderless)
            }
            .contextMenu {
                Button(model.pinnedKeys.contains(record.key) ? "Unpin" : "Pin") {
                    _ = withAnimation {
                        model.pinnedKeys.toggle(record.key)
                    }
                }
                Button("Hide") {
                    _ = withAnimation {
                        model.hiddenKeys.insert(record.key)
                    }
                }
                Button(console.captureHistoryValuesForKeys.contains(record.key) ? "Stop capturing history" : "Capture history") {
                    _ = withAnimation {
                        console.captureHistoryValuesForKeys.toggle(record.key)
                    }
                }
            }
        }
        label: {
            Text(record.key)
            .textSelection(.enabled)
        }
        .labeledContentStyle(MyLabeledContentStyle(labelWidth: 60))

    }

    func fallbackFormatter(_ value: Any) -> AnyView {
        AnyView(
            HStack {
                Text(verbatim: String(describing: value)).textSelection(.enabled)
                Image(systemName: "exclamationmark.triangle")
                    .controlSize(.mini)
                    .help("Values of type '\(String(describing: type(of: value)))' do not have a custom formatter.")

            }
        )
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

struct HistoryValueChartView: View {
    let record: Console.Record

    var body: some View {
        let items = record.historyValues.map { ($0.0, NSNumber(any: $0.1)) }
        if items.allSatisfy({ $0.1 != nil }) {
            Chart {
                ForEach(items.indices, id: \.self) { index in
                    let (date, value) = items[index]
                    LineMark(x: .value("Time", date), y: .value("Value", value!.floatValue))
                }
            }
            .frame(width: 480, height: 480)
            .padding()
        }
        else {
            Label {
                Text("Not all values are numeric.")
            }
            icon: {
                Image(systemName: "exclamationmark.triangle").foregroundColor(.yellow)
            }
            .padding()
        }
    }
}

extension NSNumber {
    convenience init?(any value: Any) {
        switch value {
        case let value as Int8:
            self.init(value: value)
        case let value as UInt8:
            self.init(value: value)
        case let value as Int16:
            self.init(value: value)
        case let value as UInt16:
            self.init(value: value)
        case let value as Int32:
            self.init(value: value)
        case let value as UInt32:
            self.init(value: value)
        case let value as Int64:
            self.init(value: value)
        case let value as UInt64:
            self.init(value: value)
        case let value as Float:
            self.init(value: value)
        case let value as Double:
            self.init(value: value)
        case let value as Bool:
            self.init(value: value)
        case let value as Int:
            self.init(value: value)
        case let value as UInt:
            self.init(value: value)
        default:
            return nil
        }
    }
}
