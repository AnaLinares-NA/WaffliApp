//
//  BottomBar.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI
import SwiftData

struct BottomBar: View {
    let onNewTask: () -> Void
    let onFox: () -> Void

    @Query private var achievements: [AchievementModel]

    var unseenCount: Int {
        achievements.filter { !$0.isSeen }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color("Waffle").opacity(0.3))
                .frame(height: 0.5)

            ZStack {
                Color("Crema")

                HStack(spacing: 50) {

                    Button(action: onFox) {
                        ZStack(alignment: .topTrailing) {
                            VStack(spacing: 3) {
                                Text("🦊")
                                    .font(.system(size: 26))

                                Text("Mi zorrito")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(Color("Cocoa").opacity(0.5))
                            }

                            if unseenCount > 0 {
                                ZStack {
                                    Circle()
                                        .fill(Color("Canela"))
                                        .frame(width: 16, height: 16)

                                    Text("\(unseenCount)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                .offset(x: 4, y: -4)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    Button(action: onNewTask) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color("Maple"), Color("Maple").opacity(0.75)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)

                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
            }
            .frame(height: 72)

            Color("Crema")
                .frame(height: 0)
                .ignoresSafeArea(edges: .bottom)
        }
        .background(Color("Crema").ignoresSafeArea(edges: .bottom))
    }
}

#Preview {
    BottomBar(onNewTask: {}, onFox: {})
}
