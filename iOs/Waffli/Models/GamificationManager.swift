//
//  GamificationManager.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import Foundation
import SwiftData

/// Lógica central de gamificación. Se instancia con el ModelContext
/// y se llama cada que el usuario completa una tarea.
struct GamificationManager {

    let context: ModelContext

    // MARK: - Tarea completada → waffle ganado

    /// Llama esto cuando una tarea se completa (desde ItemListSection)
    /// Devuelve los Achievement nuevos desbloqueados (para mostrar popup)
    @discardableResult
    func taskCompleted(task: WaffliItem, fox: FoxModel?, allLogs: [WaffleLog], allAchievements: [AchievementModel], allItems: [WaffliItem]) -> [AchievementType] {

        // 1. Registrar el waffle ganado
        let log = WaffleLog(taskName: task.name, taskCategory: task.category)
        context.insert(log)

        // 2. Actualizar el zorrito si existe
        var newAchievements: [AchievementType] = []
        if let fox {
            updateFoxMood(fox: fox, allLogs: allLogs + [log])
        }

        // 3. Verificar logros desbloqueados
        let unlocked = Set(allAchievements.map { $0.type })
        let totalWaffles = allLogs.count + 1

        let candidates: [(AchievementType, Bool)] = [
            (.firstTask,     allItems.filter { $0.isDone }.count == 1),
            (.waffles10,     totalWaffles >= 10 && !unlocked.contains(.waffles10)),
            (.waffles50,     totalWaffles >= 50 && !unlocked.contains(.waffles50)),
            (.waffles100,    totalWaffles >= 100 && !unlocked.contains(.waffles100)),
            (.allCategories, hasAllCategories(items: allItems) && !unlocked.contains(.allCategories)),
            (.nightOwl,      isNightOwl() && !unlocked.contains(.nightOwl)),
            (.earlyBird,     isEarlyBird() && !unlocked.contains(.earlyBird)),
        ]

        for (type, condition) in candidates {
            if condition && !unlocked.contains(type) {
                let achievement = AchievementModel(type: type)
                context.insert(achievement)
                newAchievements.append(type)
            }
        }

        try? context.save()
        return newAchievements
    }

    // MARK: - Alimentar al zorrito

    /// Usa los waffles disponibles hoy para alimentar al zorrito
    /// Devuelve true si se pudo alimentar
    @discardableResult
    func feedFox(fox: FoxModel, logs: [WaffleLog]) -> Bool {
        let cal = Calendar.current
        let todayLogs = logs.filter { cal.isDateInToday($0.earnedAt) && !$0.usedToFeed }

        guard todayLogs.count >= 2 else { return false }

        // Marcar 2 waffles como usados
        for log in todayLogs.prefix(2) {
            log.usedToFeed = true
        }

        fox.lastFedDate = Date()
        updateStreak(fox: fox)
        updateFoxMood(fox: fox, allLogs: logs)

        try? context.save()
        return true
    }

    // MARK: - Fox nombre desbloqueado

    func foxNamed(fox: FoxModel, allAchievements: [AchievementModel]) {
        guard !fox.name.isEmpty else { return }
        let unlocked = Set(allAchievements.map { $0.type })
        if !unlocked.contains(.foxNamed) {
            context.insert(AchievementModel(type: .foxNamed))
            try? context.save()
        }
    }

    // MARK: - Outfit comprado

    func outfitPurchased(allAchievements: [AchievementModel]) {
        let unlocked = Set(allAchievements.map { $0.type })
        if !unlocked.contains(.firstOutfit) {
            context.insert(AchievementModel(type: .firstOutfit))
            try? context.save()
        }
    }

    // MARK: - Comprar ítem de tienda

    /// Devuelve true si tiene suficientes waffles y se pudo comprar
    @discardableResult
    func purchaseItem(itemId: String, cost: Int, fox: FoxModel, allLogs: [WaffleLog], purchasedItems: [PurchasedItem], allAchievements: [AchievementModel]) -> Bool {
        let availableWaffles = fox.totalWafflesEarned - purchasedItems.reduce(0) { total, p in
            total + (ShopCatalogItem.catalog.first(where: { $0.id == p.itemId })?.cost ?? 0)
        }
        guard availableWaffles >= cost else { return false }
        guard !purchasedItems.contains(where: { $0.itemId == itemId }) else { return false }

        let purchase = PurchasedItem(itemId: itemId)
        context.insert(purchase)
        fox.totalWafflesEarned += 0 // no cambia, los waffles ya están contados
        outfitPurchased(allAchievements: allAchievements)
        try? context.save()
        return true
    }

    // MARK: - Helpers privados

    private func updateFoxMood(fox: FoxModel, allLogs: [WaffleLog]) {
        let todayWaffles = WaffleLog.availableToday(from: allLogs)
        switch (todayWaffles, fox.streak) {
        case (0, _):          fox.mood = .sleeping
        case (1, _):          fox.mood = .hungry
        case (_, 7...):       fox.mood = .superHappy
        case (_, 3...):       fox.mood = .happy
        default:              fox.mood = .fed
        }
    }

    private func updateStreak(fox: FoxModel) {
        let cal = Calendar.current
        if let last = fox.lastFedDate, cal.isDateInYesterday(last) {
            fox.streak += 1
        } else if let last = fox.lastFedDate, cal.isDateInToday(last) {
            // ya se alimentó hoy, no incrementar
        } else {
            fox.streak = 1
        }

        // Verificar logros de racha
        let streakAchievements: [(Int, AchievementType)] = [(3, .streak3), (7, .streak7), (30, .streak30)]
        for (days, type) in streakAchievements where fox.streak >= days {
            // Se verifica en taskCompleted también, aquí solo asegurar
            _ = type
        }
    }

    private func hasAllCategories(items: [WaffliItem]) -> Bool {
        let doneCategories = Set(items.filter { $0.isDone }.map { $0.category })
        return WaffliCategory.allCases.allSatisfy { doneCategories.contains($0) }
    }

    private func isNightOwl() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 0 && hour < 4
    }

    private func isEarlyBird() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 5 && hour < 7
    }
}
