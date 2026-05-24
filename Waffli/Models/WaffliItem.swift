//
//  WaffliItem.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import Foundation
import SwiftData

enum WaffliCategory: String, CaseIterable, Codable {
    case daily      = "Día a día"
    case personal   = "Personal"
    case work       = "Profesional"

    var icon: String {
        switch self {
        case .daily:    return "sun.max.fill"
        case .personal: return "person.fill"
        case .work:     return "briefcase.fill"
        }
    }

    /*
     Maple  → tareas del día (energía, acción)
     Canela → proyectos personales (creatividad, carácter)
     Cocoa  → proyectos profesionales (estructura, estabilidad)
     */
    
    var color: String {
        switch self {
        case .daily:    return "Maple"
        case .personal: return "Canela"
        case .work:     return "Cocoa"
        }
    }
}

@Model
final class WaffliItem {
    var id: UUID
    var name: String
    var desc: String
    var category: WaffliCategory
    var progress: Double      // 0.0 – 1.0
    var deadline: Date?
    var isDone: Bool
    var isArchived: Bool      // true = va a Archivados
    var archivedAt: Date?     // fecha en que se archivó
    var createdAt: Date

    init(
        name: String,
        desc: String = "",
        category: WaffliCategory = .daily,
        progress: Double = 0,
        deadline: Date? = nil
    ) {
        self.id         = UUID()
        self.name       = name
        self.desc       = desc
        self.category   = category
        self.progress   = progress
        self.deadline   = deadline
        self.isDone     = progress >= 1.0
        self.isArchived = false
        self.archivedAt = nil
        self.createdAt  = Date()
    }

    func completeAndArchive() {
        isDone      = true
        progress    = 1.0
        isArchived  = true
        archivedAt  = Date()
    }
}
