// ----------------------------------------------------------
// ConsoleLog.swift
// By: Devin Sewell - 01/04/2025
// ----------------------------------------------------------
import SwiftUI

let consoleLogManager = ConsoleLogManager()

// MARK: - Console Log Manager
class ConsoleLogManager: ObservableObject {
    @Published var consoleLogs: [String] = []
    private let MAX_CONSOLE_LOG_ITEMS = 1000
    func log(_ message: String) {
        DispatchQueue.main.async {
            self.consoleLogs.append("\(Date()):\n\(message)\n")
            self.limitLogCount()
        }
    }
    private func limitLogCount() {
        if consoleLogs.count > MAX_CONSOLE_LOG_ITEMS { consoleLogs.removeFirst(consoleLogs.count - MAX_CONSOLE_LOG_ITEMS) }
    }
}

// MARK: - Console Log View
struct ConsoleLog: View {
    @EnvironmentObject var consoleLogManager: ConsoleLogManager
    @Binding var logs: [String] // consoleLogManager.consoleLogs
    @State private var isConsoleExpanded = true // Expanded / Collapsed state
    @State private var autoScrollEnabled = true // Autoscroll Console Log
    
    @State private var isAlertPresented: Bool = false // Alert visibile bool
    @State private var alertTitle: String = "" // Alert Title
    @State private var alertMessage: String = "" // Alert Message
    @State private var confirmAction: (() -> Void)? = nil // Alert Confirm Action
    
    var body: some View {
        VStack(spacing: 0) {
            consoleLogHeaderView
            if isConsoleExpanded {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(logs.indices, id: \.self) {
                                Text(logs[$0])
                                    .foregroundColor(colorForLog(logs[$0]))
                                    .font(.caption.monospaced())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .onChange(of: logs) { _, _ in if autoScrollEnabled { withAnimation { scrollToLast(proxy) } } }
                    }
                    .padding(.horizontal)
                }
                .alert(isPresented: $isAlertPresented) {
                    Alert( // Confirm Clear Console Log
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        primaryButton: .default(Text("Yes")) {
                            confirmAction?()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .background(Color.gray.opacity(0.2))
    }
    
     var consoleLogHeaderView: some View {
        HStack {
            Text("Console Log").font(.headline)
            Button(action: shareLogs) {
                Image(systemName: "square.and.arrow.up").foregroundColor(.green)
            }
            Spacer()
            Button(action: { // Clear Console Log button
                showAlert(
                    title: "Clear Console Log ",
                    message: "Are you sure you want to erase the console log?",
                    confirmAction: {
                        logs.removeAll()
                    }
                )
            }) {
                Image(systemName: "trash").foregroundColor(.red)
            }
            .padding(.leading, 8)
            Text("Autoscroll").foregroundColor(Color(UIColor.tertiaryLabel))
            Toggle("AutoScroll", isOn: $autoScrollEnabled).toggleStyle(SwitchToggleStyle(tint: .orange)).labelsHidden()
            Button(action: { isConsoleExpanded.toggle() }) {
                Image(systemName: isConsoleExpanded ? "minus.circle" : "plus.circle").foregroundColor(.orange)
            }
        }
        .padding()
    }
    
    // Alert -> Clear Console Log
    private func showAlert(title: String, message: String, confirmAction: @escaping () -> Void) {
        self.alertTitle = title
        self.alertMessage = message
        self.confirmAction = confirmAction
        self.isAlertPresented = true
    }
    
    // Scroll to latest Console Log Item if autoscrollEnabled
    private func scrollToLast(_ proxy: ScrollViewProxy) {
        logs.indices.last.map { proxy.scrollTo($0, anchor: .bottom) }
    }
    
    // Format Console Log Item Color
    private func colorForLog(_ log: String) -> Color {
        if log.contains("Error") { return .red }
        if log.contains("Success") { return .green }
        if log.contains("func") { return .blue }
        if log.contains("DELETE") { return .red }
        return .primary
    }
    
    // Export and Share Console Log
    private func shareLogs() {
        guard !logs.isEmpty else { return print("No logs available to share.") }
        
        let logsText = "LSConsoleLog -> Console Log Output:\n-------------------------------\n\n" + logs.joined(separator: "\n\n")
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
        let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("LSConsoleLog_\(timestamp).txt")
        do {
            try logsText.write(to: tempFileURL, atomically: true, encoding: .utf8)
            let activityVC = UIActivityViewController(activityItems: [tempFileURL], applicationActivities: nil)
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = scene.windows.first?.rootViewController {
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = rootVC.view
                    popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            print("Error writing logs: \(error.localizedDescription)")
        }
    }
}
