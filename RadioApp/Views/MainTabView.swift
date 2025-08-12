//
//  MainTabView.swift
//  RadioApp
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var qsoViewModel: QSOViewModel
    @State private var selection: Int = 0
    @State private var rippleKey: Int = 0
    @Namespace private var tabNamespace
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
            // MARK: - Log QSO Tab
            NavigationView {
                LogQSOView()
            }
            .tag(0)
            .tabItem { Label("Log QSO", systemImage: "plus.circle.fill") }
            
            // MARK: - Browse Logs Tab
            NavigationView {
                BrowseLogsView()
            }
            .tag(1)
            .tabItem { Label("Browse", systemImage: "list.bullet") }
            
            // MARK: - Analytics Tab
            NavigationView {
                AnalyticsView()
            }
            .tag(2)
            .tabItem { Label("Analytics", systemImage: "chart.bar.fill") }
            
            // MARK: - Settings Tab
            NavigationView {
                SettingsView()
            }
            .tag(3)
            .tabItem { Label("Settings", systemImage: "gear") }
            }
            .onChange(of: selection) { _ in
                // Trigger ripple when selection changes via tab tap
                rippleKey &+= 1
            }

            // Water drop ripple overlay aligned to the tab bar
            HStack {
                Spacer()
                if selection == 0 { WaterRippleView(key: rippleKey).frame(width: 54, height: 54).padding(.bottom, 2) }
                if selection != 0 { Spacer() }
                if selection == 1 { WaterRippleView(key: rippleKey).frame(width: 54, height: 54).padding(.bottom, 2) }
                if selection < 1 { Spacer() }
                if selection == 2 { WaterRippleView(key: rippleKey).frame(width: 54, height: 54).padding(.bottom, 2) }
                if selection < 2 { Spacer() }
                if selection == 3 { WaterRippleView(key: rippleKey).frame(width: 54, height: 54).padding(.bottom, 2) }
                Spacer()
            }
            .allowsHitTesting(false)
            .padding(.horizontal, 16)
            .padding(.bottom, 44) // approximate tab bar height
        }
        .tint(.orange)
        .tabViewStyle(.automatic)
        .alert("Error", isPresented: $qsoViewModel.showError) {
            Button("OK") { }
        } message: {
            Text(qsoViewModel.errorMessage ?? "An unknown error occurred")
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(QSOViewModel(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
