//
//  TaskFormView.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI
import SwiftData

enum FormMode {
    case add
    case edit(WaffliItem)
}

struct TaskFormView: View {

    let context: ModelContext
    @Environment(\.dismiss) private var dismiss

    let mode: FormMode

    @State private var name: String = ""
    @State private var desc: String = ""
    @State private var category: WaffliCategory = .daily
    @State private var progress: Double = 0
    @State private var hasDeadline: Bool = false
    @State private var deadline: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var formTitle: String { isEditing ? "Editar tarea" : "Nueva tarea" }
    var catColor: Color { Color(category.color) }

    var body: some View {
        Form {
            Section("Detalles") {
                TextField("Nombre *", text: $name)
                    .foregroundStyle(Color("Cocoa"))
                TextField("Descripción (opcional)", text: $desc, axis: .vertical)
                    .lineLimit(2...4)
                    .foregroundStyle(Color("Cocoa"))
            }

            Section("Categoría") {
                Picker("Categoría", selection: $category) {
                    ForEach(WaffliCategory.allCases, id: \.self) { cat in
                        Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 6, leading: 0, bottom: 6, trailing: 0))
            }

            Section {
                Toggle(isOn: $hasDeadline) {
                    Label("Fecha límite", systemImage: "calendar.badge.clock")
                        .foregroundStyle(Color("Cocoa"))
                }
                .tint(Color("Maple"))
                if hasDeadline {
                    DatePicker(
                        "Fecha",
                        selection: $deadline,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .tint(Color("Maple"))
                }
            } header: {
                Text("Fecha límite")
            }

            Section("Avance inicial") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progreso")
                            .foregroundStyle(Color("Cocoa"))
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(catColor)
                    }
                    Slider(value: $progress, in: 0...1, step: 0.05)
                        .tint(catColor)
                }
                .padding(.vertical, 4)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("Crema").ignoresSafeArea())
        .navigationTitle(formTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("Crema"), for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancelar") { dismiss() }
                    .foregroundStyle(Color("Cocoa").opacity(0.6))
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Guardar") { save() }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("Maple"))
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear { loadExistingValues() }
        .tint(Color("Maple"))
    }

    private func loadExistingValues() {
        guard case .edit(let item) = mode else { return }
        name     = item.name
        desc     = item.desc
        category = item.category
        progress = item.progress
        if let d = item.deadline {
            hasDeadline = true
            deadline    = d
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let dl: Date? = hasDeadline ? deadline : nil

        switch mode {
        case .add:
            let newItem = WaffliItem(
                name: trimmed,
                desc: desc,
                category: category,
                progress: progress,
                deadline: dl
            )
            context.insert(newItem)
        case .edit(let item):
            item.name     = trimmed
            item.desc     = desc
            item.category = category
            item.progress = progress
            item.isDone   = progress >= 1.0
            item.deadline = dl
        }

        try? context.save()
        dismiss()
    }
}

#Preview {
    let container = try! ModelContainer(for: WaffliItem.self)

    return NavigationStack {
        TaskFormView(
            context: container.mainContext,
            mode: .add
        )
    }
}
