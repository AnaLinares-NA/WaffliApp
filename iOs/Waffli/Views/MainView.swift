//
//  MainView.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @AppStorage("waffli_username") private var userName: String = ""
    @State private var showingNewTask    = false
    @State private var navigateToProfile = false
    @State private var navigateToFox     = false

    // Popup de logro desbloqueado
    @State private var newAchievement: AchievementType? = nil
    @State private var showAchievementPopup = false

    let container: ModelContainer
    var context: ModelContext { container.mainContext }
    var displayName: String { userName.isEmpty ? "Waffler" : userName }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color("Crema").ignoresSafeArea()

                VStack(spacing: 0) {
                    WaffliHeader(displayName: displayName, navigateToProfile: $navigateToProfile)
                    HomeView(
                        showingNewTask: $showingNewTask,
                        context: context,
                        onAchievementUnlocked: { type in
                            newAchievement = type
                            withAnimation(.spring(response: 0.5)) {
                                showAchievementPopup = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                withAnimation { showAchievementPopup = false }
                            }
                        }
                    )
                }

                BottomBar(
                    onNewTask: { showingNewTask = true },
                    onFox: { navigateToFox = true }
                )
                .modelContainer(container)

                // Popup de logro desbloqueado
                if showAchievementPopup, let ach = newAchievement {
                    AchievementPopup(type: ach)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(10)
                        .padding(.top, 12)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToProfile) {
                ProfileView()
            }
            .navigationDestination(isPresented: $navigateToFox) {
                FoxView(context: context)
                    .modelContainer(container)
            }
            .sheet(isPresented: $showingNewTask) {
                NavigationStack {
                    TaskFormView(context: context, mode: .add)
                }
            }
        }
        .tint(Color("Maple"))
    }
}

// MARK: - Popup de logro

struct AchievementPopup: View {
    let type: AchievementType

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(type.color).opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: type.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(Color(type.color))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("¡Logro desbloqueado! 🎉")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color("Cocoa").opacity(0.55))
                Text(type.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color("Cocoa"))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color("Crema"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(type.color).opacity(0.3), lineWidth: 1))
        .shadow(color: Color("Maple").opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
}

#Preview {
    let container = try! ModelContainer(for: WaffliItem.self, FoxModel.self, WaffleLog.self, AchievementModel.self, PurchasedItem.self)
    return MainView(container: container)
}
