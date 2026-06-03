//
//  HomeView.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var showingNewTask: Bool
    let context: ModelContext
    var onAchievementUnlocked: ((AchievementType) -> Void)? = nil

    @Query(sort: \WaffliItem.createdAt, order: .reverse) private var items: [WaffliItem]
    @Query private var foxes: [FoxModel]
    @Query private var logs: [WaffleLog]
    @Query private var achievements: [AchievementModel]

    @State private var filter: WaffliCategory? = nil
    @State private var editItem: WaffliItem? = nil

    var activeItems: [WaffliItem] { items.filter { !$0.isArchived } }

    var filtered: [WaffliItem] {
        guard let f = filter else { return activeItems }
        return activeItems.filter { $0.category == f }
    }

    var overallProgress: Double {
        guard !activeItems.isEmpty else { return 0 }
        return activeItems.reduce(0) { $0 + $1.progress } / Double(activeItems.count)
    }

    var manager: GamificationManager { GamificationManager(context: context) }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SummaryHeader(items: activeItems, overall: overallProgress)
                CategoryFilterBar(selection: $filter)
                ItemListSection(
                    items: filtered,
                    onEdit: { editItem = $0 },
                    onDelete: delete,
                    onComplete: { item in
                        let newAchs = manager.taskCompleted(
                            task: item,
                            fox: foxes.first,
                            allLogs: logs,
                            allAchievements: achievements,
                            allItems: items
                        )
                        // Actualizar total de waffles del zorrito
                        foxes.first?.totalWafflesEarned += 1
                        try? context.save()
                        // Notificar logros nuevos
                        for ach in newAchs {
                            onAchievementUnlocked?(ach)
                        }
                    }
                )
                Spacer().frame(height: 90)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color("Crema"))
        .sheet(item: $editItem) { item in
            NavigationStack {
                TaskFormView(context: context, mode: .edit(item))
            }
        }
    }

    private func delete(_ item: WaffliItem) {
        context.delete(item)
        try? context.save()
    }
}

#Preview {
    let container = try! ModelContainer(for: WaffliItem.self, FoxModel.self, WaffleLog.self, AchievementModel.self, PurchasedItem.self)
    return HomeView(showingNewTask: .constant(false), context: container.mainContext)
        .modelContainer(container)
}
