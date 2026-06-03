//
//  FoxView.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI
import SwiftData

struct FoxView: View {
    let context: ModelContext
    @Query private var foxes: [FoxModel]
    @Query private var logs: [WaffleLog]
    @Query private var achievements: [AchievementModel]
    @Query private var purchasedItems: [PurchasedItem]

    @State private var showShop         = false
    @State private var showAchievements = false
    @State private var showNameAlert    = false
    @State private var foxNameInput     = ""
    @State private var showFeedSuccess  = false
    @State private var feedError        = false

    var fox: FoxModel? { foxes.first }

    var availableWaffles: Int {
        WaffleLog.availableToday(from: logs)
    }

    var spentWaffles: Int {
        purchasedItems.reduce(0) { total, p in
            total + (ShopCatalogItem.catalog.first(where: { $0.id == p.itemId })?.cost ?? 0)
        }
    }

    var walletWaffles: Int {
        max(0, (fox?.totalWafflesEarned ?? 0) - spentWaffles)
    }

    var equippedOutfitId: String? {
        purchasedItems.first(where: { $0.isEquipped })?.itemId
    }

    var manager: GamificationManager {
        GamificationManager(context: context)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // ── Zorrito ──
                    foxSection

                    // ── Stats del día ──
                    dailyStatsSection

                    // ── Botones de acción ──
                    actionButtons

                    // ── Logros recientes ──
                    recentAchievementsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(Color("Crema").ignoresSafeArea())
            .navigationTitle("Mi zorrito")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("Crema"), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAchievements = true
                    } label: {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(Color("Maple"))
                    }
                }
            }
            .navigationDestination(isPresented: $showShop) {
                ShopView(context: context)
            }
            .navigationDestination(isPresented: $showAchievements) {
                AchievementsView()
            }
            .alert("¿Cómo se llama tu zorrito?", isPresented: $showNameAlert) {
                TextField("Nombre", text: $foxNameInput)
                Button("Guardar") {
                    if let fox, !foxNameInput.isEmpty {
                        fox.name = foxNameInput
                        manager.foxNamed(fox: fox, allAchievements: achievements)
                    }
                }
                Button("Cancelar", role: .cancel) {}
            }
        }
        .tint(Color("Maple"))
        .onAppear { ensureFoxExists() }
    }

    // MARK: - Sections

    private var foxSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color("Waffle").opacity(0.15))
                    .frame(width: 220, height: 220)
                Circle()
                    .stroke(Color("Maple").opacity(0.2), lineWidth: 1.5)
                    .frame(width: 220, height: 220)

                FoxSVGView(
                    mood: fox?.mood ?? .sleeping,
                    outfitId: equippedOutfitId,
                    size: 180
                )
            }
            .onTapGesture { showNameAlert = true }

            // Nombre y estado
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Text(fox?.name.isEmpty == false ? fox!.name : "¿Sin nombre?")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("Cocoa"))
                    if fox?.name.isEmpty != false {
                        Image(systemName: "pencil.circle")
                            .font(.caption)
                            .foregroundStyle(Color("Maple").opacity(0.7))
                    }
                }

                HStack(spacing: 4) {
                    Text(fox?.mood.emoji ?? "😴")
                    Text(fox?.mood.label ?? "Durmiendo")
                        .font(.subheadline)
                        .foregroundStyle(Color("Cocoa").opacity(0.6))
                }

                Text(fox?.mood.description ?? "")
                    .font(.caption)
                    .foregroundStyle(Color("Cocoa").opacity(0.45))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 16)
    }

    private var dailyStatsSection: some View {
        HStack(spacing: 12) {
            StatPill(
                icon: "🧇",
                value: "\(availableWaffles)",
                label: "hoy",
                color: Color("Maple")
            )
            StatPill(
                icon: "🔥",
                value: "\(fox?.streak ?? 0)",
                label: "racha",
                color: Color("Canela")
            )
            StatPill(
                icon: "💰",
                value: "\(walletWaffles)",
                label: "total",
                color: Color("Waffle")
            )
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            // Botón de alimentar
            Button {
                feedFox()
            } label: {
                HStack(spacing: 10) {
                    Text("🧇")
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Dar de comer")
                            .font(.system(size: 15, weight: .semibold))
                        Text(availableWaffles >= 2
                             ? "Tienes \(availableWaffles) waffles disponibles"
                             : "Necesitas \(2 - availableWaffles) waffle\(2 - availableWaffles == 1 ? "" : "s") más")
                            .font(.caption)
                            .opacity(0.7)
                    }
                    Spacer()
                    Image(systemName: availableWaffles >= 2 ? "arrow.right.circle.fill" : "lock.fill")
                        .font(.title3)
                }
                .padding(14)
                .background(availableWaffles >= 2 ? Color("Maple").opacity(0.12) : Color("Cocoa").opacity(0.06))
                .foregroundStyle(availableWaffles >= 2 ? Color("Maple") : Color("Cocoa").opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(availableWaffles >= 2 ? Color("Maple").opacity(0.3) : Color("Cocoa").opacity(0.1), lineWidth: 0.5)
                )
            }
            .disabled(availableWaffles < 2)
            .buttonStyle(.plain)

            if showFeedSuccess {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color("Waffle"))
                    Text("¡Alimentado con éxito! 🎉")
                        .font(.caption).foregroundStyle(Color("Cocoa").opacity(0.7))
                }
                .transition(.scale.combined(with: .opacity))
            }

            // Botón tienda
            Button {
                showShop = true
            } label: {
                HStack(spacing: 10) {
                    Text("🛍️").font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tienda de outfits")
                            .font(.system(size: 15, weight: .semibold))
                        Text("\(walletWaffles) waffles disponibles")
                            .font(.caption).opacity(0.7)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption)
                }
                .padding(14)
                .background(Color("Waffle").opacity(0.12))
                .foregroundStyle(Color("Cocoa"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color("Waffle").opacity(0.3), lineWidth: 0.5))
            }
            .buttonStyle(.plain)
        }
    }

    private var recentAchievementsSection: some View {
        let recent = achievements.sorted { $0.unlockedAt > $1.unlockedAt }.prefix(3)
        return VStack(alignment: .leading, spacing: 10) {
            if !recent.isEmpty {
                HStack {
                    Text("Logros recientes")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color("Cocoa").opacity(0.55))
                        .textCase(.uppercase)
                        .kerning(0.5)
                    Spacer()
                    Button { showAchievements = true } label: {
                        Text("Ver todos").font(.caption).foregroundStyle(Color("Maple"))
                    }
                }
                ForEach(recent, id: \.typeRaw) { ach in
                    MiniAchievementRow(achievement: ach)
                }
            }
        }
    }

    // MARK: - Helpers

    private func ensureFoxExists() {
        if foxes.isEmpty {
            let fox = FoxModel()
            context.insert(fox)
            try? context.save()
        }
    }

    private func feedFox() {
        guard let fox else { return }
        let success = manager.feedFox(fox: fox, logs: logs)
        withAnimation(.spring(response: 0.4)) {
            showFeedSuccess = success
        }
        if success {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { showFeedSuccess = false }
            }
        }
    }
}

// MARK: - Sub-componentes

struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(icon).font(.title3)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("Cocoa").opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.2), lineWidth: 0.5))
    }
}

struct MiniAchievementRow: View {
    let achievement: AchievementModel
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color(achievement.type.color).opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: achievement.type.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(achievement.type.color))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.type.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color("Cocoa"))
                Text(achievement.unlockedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(Color("Cocoa").opacity(0.45))
            }
            Spacer()
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Color("Crema").opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("Waffle").opacity(0.2), lineWidth: 0.5))
    }
}

#Preview {
    let container = try! ModelContainer(for: FoxModel.self, WaffleLog.self, AchievementModel.self, PurchasedItem.self)
    return FoxView(context: container.mainContext)
        .modelContainer(container)
}
