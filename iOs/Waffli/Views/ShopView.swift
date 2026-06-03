//
//  ShopView.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI
import SwiftData

struct ShopView: View {
    let context: ModelContext
    @Query private var foxes: [FoxModel]
    @Query private var purchasedItems: [PurchasedItem]
    @Query private var achievements: [AchievementModel]

    @State private var selectedCategory: ShopCategory = .hat
    @State private var showBuyConfirm  = false
    @State private var pendingItem: ShopCatalogItem? = nil
    @State private var buyFeedback: String? = nil

    var fox: FoxModel? { foxes.first }

    var spentWaffles: Int {
        purchasedItems.reduce(0) { t, p in
            t + (ShopCatalogItem.catalog.first(where: { $0.id == p.itemId })?.cost ?? 0)
        }
    }

    var walletWaffles: Int {
        max(0, (fox?.totalWafflesEarned ?? 0) - spentWaffles)
    }

    var equippedOutfitId: String? {
        purchasedItems.first(where: { $0.isEquipped })?.itemId
    }

    var filteredItems: [ShopCatalogItem] {
        ShopCatalogItem.catalog.filter { $0.category == selectedCategory }
    }

    var manager: GamificationManager {
        GamificationManager(context: context)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Preview del zorrito con outfit equipado
                VStack(spacing: 8) {
                    FoxSVGView(mood: fox?.mood ?? .fed, outfitId: equippedOutfitId, size: 130)
                    Text("Vista previa")
                        .font(.caption)
                        .foregroundStyle(Color("Cocoa").opacity(0.45))
                }
                .padding(.top, 8)

                // Balance de waffles
                HStack(spacing: 6) {
                    Text("🧇")
                    Text("\(walletWaffles) waffles")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color("Maple"))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color("Maple").opacity(0.1))
                .clipShape(Capsule())

                // Selector de categoría
                HStack(spacing: 8) {
                    ForEach(ShopCategory.allCases, id: \.self) { cat in
                        Button {
                            withAnimation(.spring(response: 0.3)) { selectedCategory = cat }
                        } label: {
                            Text(cat.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(selectedCategory == cat ? Color("Maple").opacity(0.18) : Color("Waffle").opacity(0.12))
                                .foregroundStyle(selectedCategory == cat ? Color("Maple") : Color("Cocoa").opacity(0.6))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(selectedCategory == cat ? Color("Maple").opacity(0.4) : Color.clear, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Grid de ítems
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(filteredItems) { item in
                        ShopItemCard(
                            item: item,
                            isPurchased: purchasedItems.contains(where: { $0.itemId == item.id }),
                            isEquipped: equippedOutfitId == item.id,
                            canAfford: walletWaffles >= item.cost,
                            onTap: {
                                if purchasedItems.contains(where: { $0.itemId == item.id }) {
                                    equipItem(itemId: item.id)
                                } else {
                                    pendingItem = item
                                    showBuyConfirm = true
                                }
                            }
                        )
                    }
                }

                if let feedback = buyFeedback {
                    Text(feedback)
                        .font(.caption)
                        .foregroundStyle(Color("Cocoa").opacity(0.6))
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color("Crema").ignoresSafeArea())
        .navigationTitle("Tienda")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("Crema"), for: .navigationBar)
        .tint(Color("Maple"))
        .confirmationDialog(
            pendingItem != nil ? "¿Comprar \(pendingItem!.name)?" : "",
            isPresented: $showBuyConfirm,
            titleVisibility: .visible
        ) {
            if let item = pendingItem {
                Button("Comprar por \(item.cost) 🧇") { buyItem(item) }
                Button("Cancelar", role: .cancel) {}
            }
        } message: {
            if let item = pendingItem {
                Text(item.description)
            }
        }
    }

    private func buyItem(_ item: ShopCatalogItem) {
        guard let fox else { return }
        let success = manager.purchaseItem(
            itemId: item.id,
            cost: item.cost,
            fox: fox,
            allLogs: [],
            purchasedItems: purchasedItems,
            allAchievements: achievements
        )
        withAnimation {
            buyFeedback = success ? "¡\(item.name) comprado! 🎉" : "No tienes suficientes waffles 😢"
        }
        if success { equipItem(itemId: item.id) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { buyFeedback = nil } }
    }

    private func equipItem(itemId: String) {
        // Desequipar todos los del mismo tipo
        let newItem = ShopCatalogItem.catalog.first(where: { $0.id == itemId })
        for p in purchasedItems {
            let cat = ShopCatalogItem.catalog.first(where: { $0.id == p.itemId })?.category
            if cat == newItem?.category { p.isEquipped = false }
        }
        // Equipar el seleccionado (o desequipar si ya estaba equipado)
        if let p = purchasedItems.first(where: { $0.itemId == itemId }) {
            p.isEquipped = !p.isEquipped
        }
        fox?.currentOutfitId = itemId
        try? context.save()
    }
}

struct ShopItemCard: View {
    let item: ShopCatalogItem
    let isPurchased: Bool
    let isEquipped: Bool
    let canAfford: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(item.iconSymbol)
                    .font(.system(size: 36))
                    .frame(height: 48)

                Text(item.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color("Cocoa"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                if isPurchased {
                    Text(isEquipped ? "✓ Equipado" : "Equipar")
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(isEquipped ? Color("Waffle").opacity(0.25) : Color("Maple").opacity(0.12))
                        .foregroundStyle(isEquipped ? Color("Cocoa") : Color("Maple"))
                        .clipShape(Capsule())
                } else {
                    HStack(spacing: 3) {
                        Text("🧇")
                            .font(.system(size: 11))
                        Text("\(item.cost)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(canAfford ? Color("Maple") : Color("Cocoa").opacity(0.35))
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                isEquipped ? Color("Waffle").opacity(0.2) :
                isPurchased ? Color("Maple").opacity(0.06) :
                Color("Crema").opacity(0.8)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isEquipped ? Color("Waffle").opacity(0.6) :
                        isPurchased ? Color("Maple").opacity(0.2) :
                        Color("Waffle").opacity(0.25),
                        lineWidth: isEquipped ? 1.5 : 0.5
                    )
            )
            .opacity((!isPurchased && !canAfford) ? 0.55 : 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let container = try! ModelContainer(for: FoxModel.self, PurchasedItem.self, AchievementModel.self, WaffleLog.self)
    return NavigationStack {
        ShopView(context: container.mainContext)
    }
    .modelContainer(container)
}
