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

    @Query(sort: \WaffliItem.createdAt, order: .reverse) private var items: [WaffliItem]

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

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SummaryHeader(items: activeItems, overall: overallProgress)
                CategoryFilterBar(selection: $filter)
                ItemListSection(
                    items: filtered,
                    onEdit: { editItem = $0 },
                    onDelete: delete
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
