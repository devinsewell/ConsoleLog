//
//  Console_LogApp.swift
//  Console Log
//
//  Created by Devin Sewell on 1/3/25.
//

import SwiftUI
import SwiftData

@main
struct Console_LogApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(consoleLogManager)
        }
        .modelContainer(sharedModelContainer)
    }
}

