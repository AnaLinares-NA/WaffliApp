//
//  WaffliHeader.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI

struct WaffliHeader: View {
    let displayName: String
    @Binding var navigateToProfile: Bool

    private var profileImageData: Data? {
        UserDefaults.standard.data(forKey: "waffli_profile_image")
    }

    var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 6..<12:  return "Buenos días"
        case 12..<19: return "Buenas tardes"
        default:      return "Buenas noches"
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color("Cocoa"))
                .shadow(color: Color("Maple").opacity(0.22), radius: 12, x: 0, y: 5)

            Circle()
                .fill(Color("Maple").opacity(0.12))
                .frame(width: 80, height: 80)
                .blur(radius: 18)
                .offset(x: -60, y: -10)
            Circle()
                .fill(Color("Waffle").opacity(0.10))
                .frame(width: 60, height: 60)
                .blur(radius: 14)
                .offset(x: 80, y: 12)

            HStack(spacing: 0) {

                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 9))

                Spacer()

                VStack(spacing: 1) {
                    Text(greeting)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(Color("Crema").opacity(0.6))
                    Text(displayName)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("Crema"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer()

                Button {
                    navigateToProfile = true
                } label: {
                    ZStack {
                        if let data = profileImageData, let uiImg = UIImage(data: data) {
                            Image(uiImage: uiImg)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color("Maple"), Color("Waffle")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1.5
                                        )
                                )
                        } else {
                            Circle()
                                .fill(Color("Maple").opacity(0.22))
                                .frame(width: 36, height: 36)
                                .overlay(Circle().stroke(Color("Waffle").opacity(0.3), lineWidth: 1))
                            Image(systemName: "person.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color("Crema"))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 60)
        .padding(.horizontal, 14)
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
}

#Preview("Default") {
    WaffliHeader(
        displayName: "Waffler",
        navigateToProfile: .constant(false)
    )
    .padding()
    .background(Color("Crema"))
}

#Preview("Con nombre largo") {
    WaffliHeader(
        displayName: "Juán Pérez Martínez",
        navigateToProfile: .constant(false)
    )
    .padding()
    .background(Color("Crema"))
}
