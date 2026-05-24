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
    @State private var showingNewTask = false
    @State private var navigateToProfile = false

    let container: ModelContainer

    var context: ModelContext { container.mainContext }

    var displayName: String { userName.isEmpty ? "Waffler" : userName }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color("Crema").ignoresSafeArea()

                VStack(spacing: 0) {
                    WaffliHeader(displayName: displayName, navigateToProfile: $navigateToProfile)
                    HomeView(showingNewTask: $showingNewTask, context: context)
                }

                BottomBar(onNewTask: { showingNewTask = true })
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToProfile) {
                ProfileView()
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
