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
        do {
            container = try ModelContainer(for: WaffliItem.self)
        } catch {
            fatalError("No se pudo crear el ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainView(container: container)
                .modelContainer(container)
        }
    }
}
