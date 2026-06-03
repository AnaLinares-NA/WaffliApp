//
//  ShopItem.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import Foundation
import SwiftData

enum ShopCategory: String, CaseIterable {
    case hat    = "Sombreros"
    case outfit = "Ropa"
    case color  = "Color de pelaje"
}

// Catálogo estático — los ítems disponibles en la tienda
struct ShopCatalogItem: Identifiable {
    let id: String
    let name: String
    let description: String
    let cost: Int
    let category: ShopCategory
    let previewColor: String  // nombre del color Waffli o hex
    let iconSymbol: String    // SF Symbol para el preview
}

extension ShopCatalogItem {
    static let catalog: [ShopCatalogItem] = [
        // Sombreros
        ShopCatalogItem(id: "hat_waffle",   name: "Gorro de waffle",   description: "¡Literalmente un waffle en la cabeza!",  cost: 5,  category: .hat,    previewColor: "Waffle",  iconSymbol: "🧇"),
        ShopCatalogItem(id: "hat_maple",    name: "Boina Maple",       description: "Estilo parisino con toque de miel",       cost: 8,  category: .hat,    previewColor: "Maple",   iconSymbol: "🎩"),
        ShopCatalogItem(id: "hat_crown",    name: "Corona dorada",     description: "Para el zorrito más productivo",          cost: 20, category: .hat,    previewColor: "Waffle",  iconSymbol: "👑"),
        ShopCatalogItem(id: "hat_chef",     name: "Gorro de chef",     description: "El maestro wafflero",                    cost: 12, category: .hat,    previewColor: "Crema",   iconSymbol: "👨‍🍳"),
        // Ropa
        ShopCatalogItem(id: "outfit_scarf", name: "Bufanda Canela",    description: "Calientita y con estilo",                cost: 6,  category: .outfit, previewColor: "Canela",  iconSymbol: "🧣"),
        ShopCatalogItem(id: "outfit_cape",  name: "Capa de superhéroe",description: "El zorrito más heroico",                 cost: 15, category: .outfit, previewColor: "Canela",  iconSymbol: "🦸"),
        ShopCatalogItem(id: "outfit_bow",   name: "Moño elegante",     description: "Sofisticado y adorable",                 cost: 8,  category: .outfit, previewColor: "Maple",   iconSymbol: "🎀"),
        ShopCatalogItem(id: "outfit_tux",   name: "Smokin",            description: "Para ocasiones especiales",              cost: 25, category: .outfit, previewColor: "Cocoa",   iconSymbol: "🤵"),
        // Color de pelaje
        ShopCatalogItem(id: "color_maple",  name: "Pelaje Maple",      description: "Naranja dorado como la miel",            cost: 10, category: .color,  previewColor: "Maple",   iconSymbol: "🦊"),
        ShopCatalogItem(id: "color_cocoa",  name: "Pelaje Cocoa",      description: "Marrón oscuro y elegante",               cost: 10, category: .color,  previewColor: "Cocoa",   iconSymbol: "🦊"),
        ShopCatalogItem(id: "color_snow",   name: "Pelaje Crema",      description: "Blanco nevado y tierno",                 cost: 15, category: .color,  previewColor: "Crema",   iconSymbol: "🦊"),
        ShopCatalogItem(id: "color_canela", name: "Pelaje Canela",     description: "Rojizo con carácter",                    cost: 15, category: .color,  previewColor: "Canela",  iconSymbol: "🦊"),
    ]
}

// Modelo persistido: qué ítems compró el usuario
@Model
final class PurchasedItem {
    var itemId: String
    var purchasedAt: Date
    var isEquipped: Bool

    init(itemId: String) {
        self.itemId      = itemId
        self.purchasedAt = Date()
        self.isEquipped  = false
    }
}
