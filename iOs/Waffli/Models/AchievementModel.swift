//
//  AchievementModel.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import Foundation
import SwiftData

enum AchievementType: String, CaseIterable, Codable {
    // Primeras veces
    case firstTask        = "firstTask"
    case foxNamed         = "foxNamed"
    case firstOutfit      = "firstOutfit"
    // Rachas
    case streak3          = "streak3"
    case streak7          = "streak7"
    case streak30         = "streak30"
    // Waffles acumulados
    case waffles10        = "waffles10"
    case waffles50        = "waffles50"
    case waffles100       = "waffles100"
    // Categorías
    case allCategories    = "allCategories"
    // Horario
    case nightOwl         = "nightOwl"   // tarea completada después de medianoche
    case earlyBird        = "earlyBird"  // tarea completada antes de las 7am

    var title: String {
        switch self {
        case .firstTask:     return "Primera tarea"
        case .foxNamed:      return "¡Tiene nombre!"
        case .firstOutfit:   return "Fashionista"
        case .streak3:       return "Racha de 3 días"
        case .streak7:       return "Racha de 7 días"
        case .streak30:      return "Racha de 30 días"
        case .waffles10:     return "10 waffles"
        case .waffles50:     return "50 waffles"
        case .waffles100:    return "100 waffles"
        case .allCategories: return "Multitarea"
        case .nightOwl:      return "Noctámbula"
        case .earlyBird:     return "Madrugadora"
        }
    }

    var description: String {
        switch self {
        case .firstTask:     return "Completaste tu primera tarea"
        case .foxNamed:      return "Le pusiste nombre a tu zorrito"
        case .firstOutfit:   return "Compraste tu primer outfit"
        case .streak3:       return "Alimentaste al zorrito 3 días seguidos"
        case .streak7:       return "7 días consecutivos cuidando al zorrito"
        case .streak30:      return "Un mes entero de dedicación"
        case .waffles10:     return "Has ganado 10 waffles en total"
        case .waffles50:     return "50 waffles ganados — ¡eso es mucho!"
        case .waffles100:    return "100 waffles, leyenda absoluta"
        case .allCategories: return "Completaste tareas en las 3 categorías"
        case .nightOwl:      return "Completaste una tarea pasada la medianoche"
        case .earlyBird:     return "Completaste una tarea antes de las 7am"
        }
    }

    var icon: String {
        switch self {
        case .firstTask:     return "checkmark.seal.fill"
        case .foxNamed:      return "heart.fill"
        case .firstOutfit:   return "tshirt.fill"
        case .streak3:       return "flame.fill"
        case .streak7:       return "bolt.fill"
        case .streak30:      return "star.fill"
        case .waffles10:     return "gift.fill"
        case .waffles50:     return "crown.fill"
        case .waffles100:    return "trophy.fill"
        case .allCategories: return "square.grid.2x2.fill"
        case .nightOwl:      return "moon.stars.fill"
        case .earlyBird:     return "sun.horizon.fill"
        }
    }

    var color: String {
        switch self {
        case .firstTask, .allCategories: return "Maple"
        case .foxNamed, .firstOutfit:    return "Canela"
        case .streak3, .streak7, .streak30: return "Canela"
        case .waffles10, .waffles50, .waffles100: return "Waffle"
        case .nightOwl:  return "Cocoa"
        case .earlyBird: return "Maple"
        }
    }
}

@Model
final class AchievementModel {
    var typeRaw: String
    var unlockedAt: Date
    var isSeen: Bool

    init(type: AchievementType) {
        self.typeRaw    = type.rawValue
        self.unlockedAt = Date()
        self.isSeen     = false
    }

    var type: AchievementType {
        AchievementType(rawValue: typeRaw) ?? .firstTask
    }
}
