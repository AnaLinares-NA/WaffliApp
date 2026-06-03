//
//  SummaryHeader.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI

struct SummaryHeader: View {
    let items: [WaffliItem]
    let overall: Double

    var body: some View {
        VStack(spacing: 14) {
            OverallProgressRing(progress: overall)
            HStack(spacing: 10) {
                ForEach(WaffliCategory.allCases, id: \.self) { cat in
                    MiniStatCard(category: cat, items: items.filter { $0.category == cat })
                }
            }
        }
        .padding(.top, 6)
    }
}

struct OverallProgressRing: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("Waffle").opacity(0.35), lineWidth: 10)
                .frame(width: 110, height: 110)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [Color("Maple").opacity(0.7), Color("Waffle")],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .frame(width: 110, height: 110)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6), value: progress)
            VStack(spacing: 0) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("Cocoa"))
                Text("avance")
                    .font(.caption2)
                    .foregroundStyle(Color("Cocoa").opacity(0.6))
            }
        }
    }
}

struct MiniStatCard: View {
    let category: WaffliCategory
    let items: [WaffliItem]

    var avg: Double {
        guard !items.isEmpty else { return 0 }
        return items.reduce(0) { $0 + $1.progress } / Double(items.count)
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(category.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
            Text("\(Int(avg * 100))%")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Color("Cocoa"))
            Text(category.rawValue)
                .font(.system(size: 10))
                .foregroundStyle(Color("Cocoa").opacity(0.6))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color("Waffle").opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview("50%") {
    OverallProgressRing(progress: 0.5)
        .padding()
}

#Preview("Completado") {
    OverallProgressRing(progress: 1.0)
        .padding()
}

#Preview("Vacío") {
    OverallProgressRing(progress: 0.0)
        .padding()
}
