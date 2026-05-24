//
//  ArchivedView.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI
import SwiftData

struct ArchivedView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WaffliItem.archivedAt, order: .reverse) private var allItems: [WaffliItem]
    @State private var filter: WaffliCategory? = nil

    var archived: [WaffliItem] {
        let base = allItems.filter { $0.isArchived }
        guard let f = filter else { return base }
        return base.filter { $0.category == f }
    }
    var totalArchived: Int { allItems.filter { $0.isArchived }.count }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if totalArchived > 0 {
                    AchievementBanner(count: totalArchived, items: allItems.filter { $0.isArchived })
                }
                CategoryFilterBar(selection: $filter)
                if archived.isEmpty {
                    EmptyArchivedView()
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(archived) { item in
                            ArchivedCard(item: item, onRestore: restore, onDelete: delete)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color("Crema").ignoresSafeArea())
        .navigationTitle("Archivadas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("Crema"), for: .navigationBar)
        .tint(Color("Maple"))
    }

    private func restore(_ item: WaffliItem) {
        withAnimation {
            item.isArchived = false
            item.archivedAt = nil
            item.isDone     = false
            item.progress   = 0.8
        }
    }
    private func delete(_ item: WaffliItem) { context.delete(item) }
}

struct AchievementBanner: View {
    let count: Int
    let items: [WaffliItem]
    var catBreakdown: [(WaffliCategory, Int)] {
        WaffliCategory.allCases.compactMap { cat in
            let n = items.filter { $0.category == cat }.count
            return n > 0 ? (cat, n) : nil
        }
    }
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(Color("Waffle").opacity(0.25)).frame(width: 52, height: 52)
                    Image(systemName: "trophy.fill").font(.title2).foregroundStyle(Color("Maple"))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(count) completadas")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("Cocoa"))
                    Text("¡Buen trabajo, sigue así!")
                        .font(.caption).foregroundStyle(Color("Cocoa").opacity(0.6))
                }
                Spacer()
            }
            HStack(spacing: 8) {
                ForEach(catBreakdown, id: \.0) { cat, n in
                    HStack(spacing: 4) {
                        Image(systemName: cat.icon).font(.system(size: 11))
                        Text("\(n)").font(.system(size: 12, weight: .semibold))
                    }
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color(cat.color).opacity(0.13))
                    .foregroundStyle(Color(cat.color))
                    .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(Color("Waffle").opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color("Waffle").opacity(0.4), lineWidth: 0.5))
    }
}

struct ArchivedCard: View {
    let item: WaffliItem
    let onRestore: (WaffliItem) -> Void
    let onDelete: (WaffliItem) -> Void
    @State private var showDeleteConfirm = false

    var archivedDateLabel: String {
        guard let d = item.archivedAt else { return "" }
        return "Completada " + d.formatted(date: .abbreviated, time: .omitted)
    }
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill").font(.title3).foregroundStyle(Color("Waffle"))
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color("Cocoa").opacity(0.7))
                    .strikethrough(true, color: Color("Cocoa").opacity(0.3))
                if !archivedDateLabel.isEmpty {
                    Text(archivedDateLabel).font(.caption2).foregroundStyle(Color("Cocoa").opacity(0.45))
                }
            }
            Spacer()
            CategoryBadge(category: item.category).opacity(0.7)
            Menu {
                Button { onRestore(item) } label: { Label("Restaurar", systemImage: "arrow.uturn.backward") }
                Button(role: .destructive) { showDeleteConfirm = true } label: { Label("Eliminar", systemImage: "trash") }
            } label: {
                Image(systemName: "ellipsis").font(.caption).foregroundStyle(Color("Cocoa").opacity(0.4)).padding(8)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Color("Crema").opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color("Waffle").opacity(0.2), lineWidth: 0.5))
        .confirmationDialog("¿Eliminar \"\(item.name)\"?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Eliminar", role: .destructive) { onDelete(item) }
            Button("Cancelar", role: .cancel) {}
        }
    }
}

struct EmptyArchivedView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "archivebox").font(.system(size: 40)).foregroundStyle(Color("Maple").opacity(0.35))
            Text("Sin archivadas aún").font(.headline).foregroundStyle(Color("Cocoa").opacity(0.7))
            Text("Completa una tarea y aparecerá aquí").font(.subheadline).foregroundStyle(Color("Cocoa").opacity(0.45))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 50)
    }
}
