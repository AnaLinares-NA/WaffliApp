//
//  WaffliApp.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI
import SwiftData

@main
struct WaffliApp: App {

    let container: ModelContainer

    init() {
        let schema = Schema([
            WaffliItem.self,
            FoxModel.self,
            WaffleLog.self,
            AchievementModel.self,
            PurchasedItem.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            let url = URL.applicationSupportDirectory.appending(path: "default.store")
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.removeItem(at: url.appendingPathExtension("shm"))
            try? FileManager.default.removeItem(at: url.appendingPathExtension("wal"))
            container = try! ModelContainer(for: schema, configurations: config)
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView(container: container)
                .modelContainer(container)
        }
    }
}
