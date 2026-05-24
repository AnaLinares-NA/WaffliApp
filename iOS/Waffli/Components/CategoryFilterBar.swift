//
//  CategoryFilterBar.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI

struct CategoryFilterBar: View {
    @Binding var selection: WaffliCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    label: "Todos",
                    icon: "square.grid.2x2",
                    isSelected: selection == nil,
                    color: Color("Maple")
                ) {
                    selection = nil
                }
                ForEach(WaffliCategory.allCases, id: \.self) { cat in
                    FilterChip(
                        label: cat.rawValue,
                        icon: cat.icon,
                        isSelected: selection == cat,
                        color: Color(cat.color)
                    ) {
                        selection = cat
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    var color: Color = Color("Maple")
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.caption)
                Text(label).font(.subheadline).fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? color.opacity(0.18) : Color("Waffle").opacity(0.15))
            .foregroundStyle(isSelected ? color : Color("Cocoa").opacity(0.7))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? color.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
