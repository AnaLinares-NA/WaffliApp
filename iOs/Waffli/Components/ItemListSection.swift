//
//  ItemListSection.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI

struct ItemListSection: View {
    let items: [WaffliItem]
    let onEdit: (WaffliItem) -> Void
    let onDelete: (WaffliItem) -> Void
    var onComplete: ((WaffliItem) -> Void)? = nil

    var body: some View {
        if items.isEmpty {
            EmptyStateView()
        } else {
            LazyVStack(spacing: 10) {
                ForEach(items) { item in
                    ItemCard(item: item, onEdit: onEdit, onDelete: onDelete, onComplete: onComplete)
                }
            }
        }
    }
}

struct ItemCard: View {
    @Bindable var item: WaffliItem
    let onEdit: (WaffliItem) -> Void
    let onDelete: (WaffliItem) -> Void
    var onComplete: ((WaffliItem) -> Void)? = nil

    @State private var showDeleteConfirm = false
    @State private var justCompleted = false
    private let catColor: Color

    init(item: WaffliItem, onEdit: @escaping (WaffliItem) -> Void, onDelete: @escaping (WaffliItem) -> Void, onComplete: ((WaffliItem) -> Void)? = nil) {
        self.item       = item
        self.onEdit     = onEdit
        self.onDelete   = onDelete
        self.onComplete = onComplete
        self.catColor   = Color(item.category.color)
    }

    var deadlineLabel: String? {
        guard let d = item.deadline else { return nil }
        let diff = Calendar.current.dateComponents([.day], from: Date(), to: d).day ?? 0
        if diff < 0 { return "Vencido" }
        if diff == 0 { return "Hoy" }
        if diff == 1 { return "Mañana" }
        return d.formatted(date: .abbreviated, time: .omitted)
    }

    var deadlineColor: Color {
        guard let d = item.deadline else { return Color("Cocoa").opacity(0.5) }
        let diff = Calendar.current.dateComponents([.day], from: Date(), to: d).day ?? 0
        if diff < 0  { return Color("Canela") }
        if diff <= 1 { return Color("Maple")  }
        return Color("Cocoa").opacity(0.5)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Button { handleToggle() } label: {
                    Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(item.isDone ? Color("Waffle") : Color("Cocoa").opacity(0.3))
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(item.isDone ? Color("Cocoa").opacity(0.45) : Color("Cocoa"))
                        .strikethrough(item.isDone, color: Color("Cocoa").opacity(0.4))
                    if !item.desc.isEmpty {
                        Text(item.desc)
                            .font(.caption)
                            .foregroundStyle(Color("Cocoa").opacity(0.55))
                            .lineLimit(2)
                    }
                }
                Spacer()
                CategoryBadge(category: item.category)
            }

            VStack(spacing: 4) {
                HStack {
                    if let label = deadlineLabel {
                        Label(label, systemImage: "calendar")
                            .font(.caption2)
                            .foregroundStyle(deadlineColor)
                    }
                    Spacer()
                    Text("\(Int(item.progress * 100))%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(catColor)
                }
                Slider(value: Binding(
                    get: { item.progress },
                    set: { val in handleSlider(val) }
                ), in: 0...1, step: 0.05)
                .tint(catColor)
            }

            HStack {
                Spacer()
                Button { onEdit(item) } label: {
                    Label("Editar", systemImage: "pencil").font(.caption)
                }
                .buttonStyle(.borderless).foregroundStyle(Color("Maple"))
                Divider().frame(height: 12).overlay(Color("Cocoa").opacity(0.2))
                Button(role: .destructive) { showDeleteConfirm = true } label: {
                    Label("Eliminar", systemImage: "trash").font(.caption)
                }
                .buttonStyle(.borderless).foregroundStyle(Color("Canela"))
            }
        }
        .padding(14)
        .background(
            ZStack {
                Color("Crema").opacity(0.85)
                if justCompleted { Color("Waffle").opacity(0.25).transition(.opacity) }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(justCompleted ? Color("Waffle").opacity(0.7) : Color("Waffle").opacity(0.3),
                        lineWidth: justCompleted ? 1.5 : 0.5)
        )
        .confirmationDialog("¿Eliminar \"\(item.name)\"?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Eliminar", role: .destructive) { onDelete(item) }
            Button("Cancelar", role: .cancel) {}
        }
    }

    private func handleToggle() {
        withAnimation(.spring(response: 0.4)) {
            if !item.isDone {
                triggerComplete()
            } else {
                item.isDone = false; item.progress = 0.8
                item.isArchived = false; item.archivedAt = nil
            }
        }
    }

    private func handleSlider(_ val: Double) {
        item.progress = val
        if val >= 1.0 && !item.isDone { triggerComplete() }
        else if val < 1.0 { item.isDone = false; item.isArchived = false; item.archivedAt = nil }
    }

    private func triggerComplete() {
        justCompleted = true
        onComplete?(item) // 🧇 dispara gamificación
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.4)) { item.completeAndArchive() }
        }
    }
}

struct CategoryBadge: View {
    let category: WaffliCategory
    var body: some View {
        HStack(spacing: 4) {
            Image(category.icon).resizable().scaledToFit().frame(width: 12, height: 12)
            Text(category.rawValue).font(.system(size: 10, weight: .medium))
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(Color(category.color).opacity(0.15))
        .foregroundStyle(Color(category.color))
        .clipShape(Capsule())
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image("Vacio").resizable().scaledToFit().frame(width: 120, height: 120)
            Text("Nada aquí todavía").font(.headline).foregroundStyle(Color("Cocoa").opacity(0.7))
            Text("Toca + para crear tu nueva tarea").font(.subheadline).foregroundStyle(Color("Cocoa").opacity(0.45))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 50)
    }
}

#Preview {
    ItemListSection(
        items: WaffliPreviewData.items,
        onEdit: { _ in },
        onDelete: { _ in }
    )
    .padding()
}
