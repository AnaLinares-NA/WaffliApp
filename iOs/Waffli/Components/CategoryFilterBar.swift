//
//  CategoryFilterBar.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI

struct CategoryFilterBar: View {
    @Binding var selection: WaffliCategory?
    @State private var didAppear = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {

                FilterChip(
                    label: "Todos",
                    imageName: "F_Todos",
                    isSelected: selection == nil,
                    color: Color("Maple"),
                    triggerEntrance: didAppear,
                    entranceDelay: 0.0
                ) { selection = nil }

                ForEach(Array(WaffliCategory.allCases.enumerated()), id: \.element) { index, cat in
                    FilterChip(
                        label: cat.rawValue,
                        imageName: cat.icon,
                        isSelected: selection == cat,
                        color: Color(cat.color),
                        triggerEntrance: didAppear,
                        entranceDelay: Double(index + 1) * 0.09
                    ) { selection = cat }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                didAppear = true
            }
        }
    }
}

struct FilterChip: View {
    let label: String
    let imageName: String
    let isSelected: Bool
    var color: Color = Color("Maple")
    let triggerEntrance: Bool
    let entranceDelay: Double
    let action: () -> Void

    @State private var rotation: Double = 0      // baile al tocar
    @State private var jumpScale: Double = 0.5   // salto de entrada
    @State private var jumpOffset: Double = 6    // desplazamiento vertical entrada
    @State private var hasJumped = false

    var body: some View {
        Button {
            action()
            dance()
        } label: {
            HStack(spacing: 5) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(jumpScale)
                    .offset(y: jumpOffset)

                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? color.opacity(0.18) : Color("Waffle").opacity(0.15))
            .foregroundStyle(isSelected ? color : Color("Cocoa").opacity(0.7))
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(isSelected ? color.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
        .onChange(of: triggerEntrance) { _, newVal in
            guard newVal, !hasJumped else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + entranceDelay) {
                // Salta hacia arriba
                withAnimation(.spring(response: 0.20, dampingFraction: 0.40)) {
                    jumpScale  = 1.0
                    jumpOffset = 0
                    hasJumped  = true
                }
            }
        }
    }

    // Oscilación izquierda-derecha-izquierda-centro
    private func dance() {
        let steps: [(delay: Double, angle: Double, duration: Double)] = [
            (0.00,  14, 0.10),
            (0.10, -11, 0.10),
            (0.20,   8, 0.09),
            (0.29,  -5, 0.08),
            (0.37,   0, 0.12),
        ]
        for step in steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + step.delay) {
                withAnimation(.easeInOut(duration: step.duration)) {
                    rotation = step.angle
                }
            }
        }
    }
}

#Preview {
    CategoryFilterBar(selection: .constant(nil))
        .padding()
}
