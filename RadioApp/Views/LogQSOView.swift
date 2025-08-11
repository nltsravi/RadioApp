//
//  LogQSOView.swift
//  RadioApp
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//

import SwiftUI

struct LogQSOView: View {
    @EnvironmentObject var qsoViewModel: QSOViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingQuickLog = false
    @State private var showingFullLog = false
    @State private var qsoData = QSOData()
    
    // Quick log fields
    @State private var quickCallsign = ""
    @State private var quickBand = "20m"
    @State private var quickMode = "SSB"
    @State private var quickRstSent = "59"
    @State private var quickRstReceived = "59"
    @State private var quickPower = 100.0
    @State private var quickStation: StationProfile?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Header
                VStack(spacing: 8) {
                    Text("QSO Log")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Quick logging for amateur radio operators")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // MARK: - Quick Log Button
                Button(action: {
                    showingQuickLog = true
                }) {
                    VStack(spacing: 14) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(.orange)

                        Text("Log QSO")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Fast entry – under 5 seconds")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 36)
                    .padding(.horizontal)
                    .cardStyle()
                }
                .buttonStyle(PlainButtonStyle())
                
                // MARK: - Recent QSOs
                if !qsoViewModel.qsos.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent QSOs")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 10) {
                            ForEach(Array(qsoViewModel.qsos.prefix(5)), id: \.id) { qso in
                                RecentQSOView(qso: qso)
                            }
                        }
                    }
                }
                
                // MARK: - Quick Stats
                if let analytics = qsoViewModel.analytics {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Activity")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            StatCard(
                                title: "Total QSOs",
                                value: "\(analytics.totalQSOs)",
                                icon: "radio.fill",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Unique Calls",
                                value: "\(analytics.uniqueCallsigns)",
                                icon: "person.2.fill",
                                color: .green
                            )
                            
                            StatCard(
                                title: "DXCC Entities",
                                value: "\(analytics.dxccEntities)",
                                icon: "globe",
                                color: .orange
                            )
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .background(AppTheme.groupBackground)
        .sheet(isPresented: $showingQuickLog) {
            QuickLogView(
                callsign: $quickCallsign,
                band: $quickBand,
                mode: $quickMode,
                rstSent: $quickRstSent,
                rstReceived: $quickRstReceived,
                power: $quickPower,
                station: $quickStation,
                onSave: saveQuickQSO
            )
        }
        .sheet(isPresented: $showingFullLog) {
            FullLogView(qsoData: $qsoData, onSave: saveFullQSO)
        }
    }
    
    private func saveQuickQSO() {
        let qsoData = QSOData(
            datetime: Date(),
            callsign: quickCallsign,
            band: quickBand,
            mode: quickMode,
            rstSent: quickRstSent,
            rstReceived: quickRstReceived,
            txPowerW: quickPower,
            station: quickStation
        )
        
        qsoViewModel.addQSO(qsoData)
        
        // Reset form
        quickCallsign = ""
        quickBand = "20m"
        quickMode = "SSB"
        quickRstSent = "59"
        quickRstReceived = "59"
        quickPower = 100.0
        quickStation = nil
        
        showingQuickLog = false
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func saveFullQSO() {
        qsoViewModel.addQSO(qsoData)
        qsoData = QSOData()
        showingFullLog = false
    }
}

// MARK: - Recent QSO View
struct RecentQSOView: View {
    let qso: QSO
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(qso.callsign ?? "Unknown")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(qso.band ?? "") \(qso.mode ?? "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(qso.datetime?.formatted(date: .abbreviated, time: .shortened) ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    if qso.qslSent {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    if qso.qslReceived {
                        Image(systemName: "envelope.badge.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    LogQSOView()
        .environmentObject(QSOViewModel(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
