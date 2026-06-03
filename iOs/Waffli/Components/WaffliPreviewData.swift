//
//  WaffliPreviewData.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 25/05/26.
//

import SwiftUI

enum WaffliPreviewData {
    static let items: [WaffliItem] = [
        .preview(name: "SwiftUI", category: .work, progress: 0.8),
        .preview(name: "Gym", category: .daily, progress: 0.4),
        .preview(name: "Proyecto personal", category: .personal, progress: 1.0, isDone: true, isArchived: true)
    ]
}

#Preview {
    VStack(spacing: 10) {
        ForEach(WaffliCategory.allCases, id: \.self) { cat in
            HStack(spacing: 10) {
                Image(systemName: cat.icon)
                    .foregroundStyle(Color(cat.color))

                Text(cat.rawValue)
                    .foregroundStyle(Color("Cocoa"))

                Spacer()

                Circle()
                    .fill(Color(cat.color))
                    .frame(width: 12, height: 12)
            }
            .padding()
            .background(Color("Crema"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    .padding()
}
