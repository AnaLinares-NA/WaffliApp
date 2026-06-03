//
//  AchievementsView.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Query private var achievements: [AchievementModel]

    var unlockedIds: Set<AchievementType> {
        Set(achievements.map { $0.type })
    }

    var unlockedCount: Int { unlockedIds.count }
    var totalCount: Int   { AchievementType.allCases.count }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Progreso general
                VStack(spacing: 8) {
                    HStack {
                        Text("\(unlockedCount) / \(totalCount) logros")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color("Cocoa"))
                        Spacer()
                        Text("\(Int(Double(unlockedCount) / Double(totalCount) * 100))%")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("Maple"))
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color("Waffle").opacity(0.2)).frame(height: 8)
                            Capsule().fill(Color("Maple").opacity(0.8))
                                .frame(width: geo.size.width * (Double(unlockedCount) / Double(totalCount)), height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(14)
                .background(Color("Waffle").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                // Lista de logros
                LazyVStack(spacing: 8) {
                    ForEach(AchievementType.allCases, id: \.self) { type in
                        let isUnlocked = unlockedIds.contains(type)
                        let achievementDate = achievements.first(where: { $0.type == type })?.unlockedAt

                        AchievementRow(
                            type: type,
                            isUnlocked: isUnlocked,
                            unlockedAt: achievementDate
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
            .padding(.top, 8)
        }
        .background(Color("Crema").ignoresSafeArea())
        .navigationTitle("Logros")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("Crema"), for: .navigationBar)
        .tint(Color("Maple"))
    }
}

struct AchievementRow: View {
    let type: AchievementType
    let isUnlocked: Bool
    let unlockedAt: Date?

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked
                          ? Color(type.color).opacity(0.18)
                          : Color("Cocoa").opacity(0.06))
                    .frame(width: 48, height: 48)
                if isUnlocked {
                    Image(systemName: type.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(Color(type.color))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color("Cocoa").opacity(0.25))
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(isUnlocked ? type.title : "???")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(isUnlocked ? Color("Cocoa") : Color("Cocoa").opacity(0.35))
                Text(isUnlocked ? type.description : "Sigue completando tareas para descubrirlo")
                    .font(.caption)
                    .foregroundStyle(Color("Cocoa").opacity(isUnlocked ? 0.55 : 0.3))
                    .lineLimit(2)
                if let date = unlockedAt {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(Color(type.color).opacity(0.7))
                }
            }

            Spacer()

            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color(type.color).opacity(0.7))
                    .font(.title3)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(isUnlocked ? Color("Crema").opacity(0.85) : Color("Crema").opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isUnlocked ? Color(type.color).opacity(0.2) : Color("Cocoa").opacity(0.08),
                    lineWidth: 0.5
                )
        )
        .opacity(isUnlocked ? 1 : 0.7)
    }
}

#Preview {
    let container = try! ModelContainer(for: AchievementModel.self)
    return NavigationStack {
        AchievementsView()
    }
    .modelContainer(container)
}
