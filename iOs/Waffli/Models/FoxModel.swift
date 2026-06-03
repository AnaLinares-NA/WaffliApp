//
//  FoxModel.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import Foundation
import SwiftData

enum FoxMood: String, Codable, CaseIterable {
    case sleeping    = "sleeping"
    case hungry      = "hungry"
    case fed         = "fed"
    case happy       = "happy"
    case superHappy  = "superHappy"

    var label: String {
        switch self {
        case .sleeping:   return "Durmiendo"
        case .hungry:     return "Con hambre"
        case .fed:        return "Satisfecho"
        case .happy:      return "Feliz"
        case .superHappy: return "¡Súper feliz!"
        }
    }

    var emoji: String {
        switch self {
        case .sleeping:   return "😴"
        case .hungry:     return "🍽️"
        case .fed:        return "😊"
        case .happy:      return "🎉"
        case .superHappy: return "🌟"
        }
    }

    var description: String {
        switch self {
        case .sleeping:   return "No has completado tareas hoy"
        case .hungry:     return "¡Le falta 1 waffle para estar satisfecho!"
        case .fed:        return "¡Bien alimentado hoy!"
        case .happy:      return "¡Llevas varios días seguidos!"
        case .superHappy: return "¡Racha de 7 días! ¡Increíble!"
        }
    }
}

@Model
final class FoxModel {
    var name: String
    var moodRaw: String
    var totalWafflesEarned: Int   // acumulado histórico
    var currentOutfitId: String?  // outfit equipado
    var lastFedDate: Date?
    var streak: Int               // días consecutivos alimentado
    var createdAt: Date

    init(name: String = "") {
        self.name               = name
        self.moodRaw            = FoxMood.sleeping.rawValue
        self.totalWafflesEarned = 0
        self.currentOutfitId    = nil
        self.lastFedDate        = nil
        self.streak             = 0
        self.createdAt          = Date()
    }

    var mood: FoxMood {
        get { FoxMood(rawValue: moodRaw) ?? .sleeping }
        set { moodRaw = newValue.rawValue }
    }
}
