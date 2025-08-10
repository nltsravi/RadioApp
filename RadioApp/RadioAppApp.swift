//
//  RadioAppApp.swift
//  RadioApp
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//

import SwiftUI

@main
struct RadioAppApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var qsoViewModel: QSOViewModel
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showSplash = true
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _qsoViewModel = StateObject(wrappedValue: QSOViewModel(context: context))
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(qsoViewModel)
                    .environmentObject(authViewModel)
                    .zIndex(0)

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                // Dismiss splash after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
