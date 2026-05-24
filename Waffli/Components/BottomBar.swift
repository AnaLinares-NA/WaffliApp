//
//  BottomBar.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI

struct BottomBar: View {
    let onNewTask: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Línea separadora sutil
            Rectangle()
                .fill(Color("Waffle").opacity(0.3))
                .frame(height: 0.5)

            ZStack {
                Color("Crema")

                // Botón Central: Nueva tarea
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
                            .shadow(color: Color("Maple").opacity(0.35), radius: 10, x: 0, y: 4)

                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
            }
            .frame(height: 72)

            // Safe area extra para iPhone con home indicator
            Color("Crema")
                .frame(height: 0)
                .ignoresSafeArea(edges: .bottom)
        }
        .background(Color("Crema").ignoresSafeArea(edges: .bottom))
    }
}
