// ----------------------------------------------------------
// ContentView.swift
// By: Devin Sewell - 01/04/2025
// ----------------------------------------------------------
import SwiftUI
import SwiftData

@Model
final class Item {
    var timestamp: Date
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

// MARK: - Default SwiftUI App Template
struct ContentView: View {
    @StateObject private var consoleLogManager = ConsoleLogManager()
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink(destination: itemDetailView(for: item)) {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
                ToolbarItem { Button(action: addItem) { Label("Add Item", systemImage: "plus") }
                }
            }
        } detail: {
            Text("Select an item")
        }
        .onAppear {
            consoleLogManager.log("ContentView appeared: Ready.")
            consoleLogManager.log("Success -> Loaded \(items.count) items.")
        }
        // ConsoleLog View
        ConsoleLog(logs: $consoleLogManager.consoleLogs)
    }

    private func addItem() {
        consoleLogManager.log("private func addItem()")
        withAnimation {
            let newItem = Item(timestamp: Date())
            consoleLogManager.log("ADD ITEM: \(newItem.timestamp)")
            modelContext.insert(newItem)
        }
        consoleLogManager.log("Success -> addItem()")
    }

    private func deleteItems(offsets: IndexSet) {
        consoleLogManager.log("private func deleteItems(offsets: IndexSet)")
        withAnimation {
            for index in offsets {
                consoleLogManager.log("DELETE ITEM: \(items[index])")
                modelContext.delete(items[index])
            }
        }
        consoleLogManager.log("Success -> deleteItems()")
    }
    
    private func itemDetailView(for item: Item) -> some View {
        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
            .onAppear { consoleLogManager.log("NAVIGATED TO ITEM: \(item.timestamp)") }
            .onDisappear{ consoleLogManager.log("NAVIGATED TO: ContentView") }
    }
}

#Preview {
    ContentView().modelContainer(for: Item.self, inMemory: true)
}
