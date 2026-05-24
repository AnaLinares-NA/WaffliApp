//
//  ProfileView.swift
//  Waffli
//
//  Created by Ana Linares Guzmán on 23/05/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @Query private var allItems: [WaffliItem]

    @AppStorage("waffli_username") private var userName: String = ""
    @State private var editingName = false
    @State private var tempName = ""

    // Foto de perfil
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    @State private var profileImageData: Data? = UserDefaults.standard.data(forKey: "waffli_profile_image")

    var activeItems: [WaffliItem]   { allItems.filter { !$0.isArchived } }
    var archivedItems: [WaffliItem] { allItems.filter { $0.isArchived  } }

    var overallProgress: Double {
        guard !activeItems.isEmpty else { return 0 }
        return activeItems.reduce(0) { $0 + $1.progress } / Double(activeItems.count)
    }

    var streakDays: Int {
        guard !archivedItems.isEmpty else { return 0 }
        let cal = Calendar.current
        var streak = 0
        var checkDate = Date()
        for _ in 0..<60 {
            let hasActivity = archivedItems.contains {
                guard let d = $0.archivedAt else { return false }
                return cal.isDate(d, inSameDayAs: checkDate)
            }
            if hasActivity { streak += 1 }
            else if streak > 0 { break }
            checkDate = cal.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        return streak
    }

    var displayName: String { userName.isEmpty ? "Waffler" : userName }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:  return "Buenos días"
        case 12..<19: return "Buenas tardes"
        default:      return "Buenas noches"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                ZStack {
                    Color("Waffle").opacity(0.18)

                    VStack(spacing: 14) {

                        PhotosPicker(
                            selection: $selectedPhoto,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            ZStack(alignment: .bottomTrailing) {

                                Group {
                                    if let profileImage {
                                        profileImage
                                            .resizable()
                                            .scaledToFill()
                                    } else if let data = profileImageData,
                                              let uiImg = UIImage(data: data) {
                                        Image(uiImage: uiImg)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        // En caso de no haber foto se muestra icono m. + fondo cálido
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color("Waffle").opacity(0.4), Color("Maple").opacity(0.2)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                            Image("Icono")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 46, height: 46)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                }
                                .frame(width: 88, height: 88)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color("Maple"), Color("Waffle")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2.5
                                        )
                                )
                                .shadow(color: Color("Maple").opacity(0.2), radius: 8, x: 0, y: 4)

                                // Badge cámara
                                ZStack {
                                    Circle()
                                        .fill(Color("Maple"))
                                        .frame(width: 28, height: 28)
                                        .shadow(color: Color("Cocoa").opacity(0.25), radius: 4, x: 0, y: 2)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                .offset(x: 3, y: 3)
                            }
                        }
                        .buttonStyle(.plain)
                        .onChange(of: selectedPhoto) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    profileImageData = data
                                    UserDefaults.standard.set(data, forKey: "waffli_profile_image")
                                    if let uiImg = UIImage(data: data) {
                                        profileImage = Image(uiImage: uiImg)
                                    }
                                }
                            }
                        }

                        if editingName {
                            HStack(spacing: 8) {
                                TextField("Tu nombre", text: $tempName)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color("Cocoa"))
                                    .multilineTextAlignment(.center)
                                    .submitLabel(.done)
                                    .onSubmit { saveName() }
                                Button { saveName() } label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color("Maple"))
                                }
                            }
                            .padding(.horizontal, 40)
                        } else {
                            Button {
                                tempName = userName
                                editingName = true
                            } label: {
                                HStack(spacing: 6) {
                                    Text(displayName)
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color("Cocoa"))
                                    Image(systemName: "pencil.circle")
                                        .font(.caption)
                                        .foregroundStyle(Color("Maple").opacity(0.7))
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        Text("\(greeting) ✦")
                            .font(.subheadline)
                            .foregroundStyle(Color("Cocoa").opacity(0.55))
                    }
                    .padding(.vertical, 28)
                }
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0, bottomLeadingRadius: 28,
                        bottomTrailingRadius: 28, topTrailingRadius: 0
                    )
                )

                VStack(spacing: 20) {

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(icon: "chart.bar.fill", title: "Tu progreso")
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            StatTile(value: "\(Int(overallProgress * 100))%", label: "Avance general", icon: "target",             color: Color("Maple"))
                            StatTile(value: "\(archivedItems.count)",          label: "Completadas",    icon: "checkmark.seal.fill", color: Color("Waffle"))
                            StatTile(value: "\(activeItems.count)",            label: "En progreso",    icon: "flame.fill",          color: Color("Canela"))
                            StatTile(value: "\(streakDays)d",                  label: "Racha actual",   icon: "bolt.fill",           color: Color("Cocoa"))
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(icon: "square.grid.2x2.fill", title: "Por categoría")
                        VStack(spacing: 8) {
                            ForEach(WaffliCategory.allCases, id: \.self) { cat in
                                CategoryProgressRow(category: cat, items: allItems.filter { $0.category == cat })
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel(icon: "folder.fill", title: "Historial")
                        NavigationLink(destination: ArchivedView()) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("Waffle").opacity(0.2))
                                        .frame(width: 38, height: 38)
                                    Image(systemName: "archivebox.fill")
                                        .foregroundStyle(Color("Maple"))
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Ver archivadas")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(Color("Cocoa"))
                                    Text("\(archivedItems.count) tareas completadas")
                                        .font(.caption)
                                        .foregroundStyle(Color("Cocoa").opacity(0.5))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Color("Cocoa").opacity(0.35))
                            }
                            .padding(14)
                            .background(Color("Crema").opacity(0.85))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color("Waffle").opacity(0.3), lineWidth: 0.5))
                        }
                        .buttonStyle(.plain)
                    }

                    HStack(spacing: 6) {
                        Image("Icono")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        Text("Waffli · hecho con 🧇")
                            .font(.caption2)
                            .foregroundStyle(Color("Cocoa").opacity(0.3))
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 32)
                }
                .padding(16)
            }
        }
        .background(Color("Crema").ignoresSafeArea())
        .navigationTitle("Mi perfil")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("Crema"), for: .navigationBar)
        .tint(Color("Maple"))
    }

    private func saveName() {
        userName = tempName.trimmingCharacters(in: .whitespaces)
        editingName = false
    }
}

// MARK: - Sub-componentes del perfil

struct SectionLabel: View {
    let icon: String
    let title: String
    var body: some View {
        Label(title, systemImage: icon)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color("Cocoa").opacity(0.55))
            .textCase(.uppercase)
            .kerning(0.5)
    }
}

struct StatTile: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).font(.title3).foregroundStyle(color)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color("Cocoa"))
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("Cocoa").opacity(0.55))
                .lineLimit(1).minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.2), lineWidth: 0.5))
    }
}

struct CategoryProgressRow: View {
    let category: WaffliCategory
    let items: [WaffliItem]
    var done: Int  { items.filter { $0.isArchived }.count }
    var total: Int { items.count }
    var avg: Double {
        guard !items.isEmpty else { return 0 }
        return items.reduce(0) { $0 + $1.progress } / Double(items.count)
    }
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .frame(width: 20)
                .foregroundStyle(Color(category.color))
                .font(.subheadline)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(category.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color("Cocoa"))
                    Spacer()
                    Text("\(done)/\(total)")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(Color("Cocoa").opacity(0.5))
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color(category.color).opacity(0.15)).frame(height: 5)
                        Capsule().fill(Color(category.color).opacity(0.7))
                            .frame(width: geo.size.width * avg, height: 5)
                    }
                }
                .frame(height: 5)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Color("Crema").opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color("Waffle").opacity(0.2), lineWidth: 0.5))
    }
}
