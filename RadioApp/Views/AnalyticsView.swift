//
//  AnalyticsView.swift
//  RadioApp
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var qsoViewModel: QSOViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Overview Cards
                if let analytics = qsoViewModel.analytics {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        AnalyticsCard(
                            title: "Total QSOs",
                            value: "\(analytics.totalQSOs)",
                            icon: "radio.fill",
                            color: .blue
                        )
                        
                        AnalyticsCard(
                            title: "Unique Calls",
                            value: "\(analytics.uniqueCallsigns)",
                            icon: "person.2.fill",
                            color: .green
                        )
                        
                        AnalyticsCard(
                            title: "DXCC Entities",
                            value: "\(analytics.dxccEntities)",
                            icon: "globe",
                            color: .orange
                        )
                        
                        AnalyticsCard(
                            title: "QSL Sent",
                            value: "\(analytics.qslSentCount)",
                            icon: "envelope.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // MARK: - QSOs by Band Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("QSOs by Band")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if !analytics.qsosByBand.isEmpty {
                            Chart {
                                ForEach(Array(analytics.qsosByBand.sorted(by: { $0.value > $1.value }).prefix(10)), id: \.key) { band, count in
                                    BarMark(
                                        x: .value("Band", band),
                                        y: .value("Count", count)
                                    )
                                    .foregroundStyle(Color.blue.gradient)
                                }
                            }
                            .frame(height: 200)
                            .padding(.horizontal)
                        } else {
                            EmptyChartView(message: "No QSOs logged yet")
                        }
                    }
                    
                    // MARK: - QSOs by Mode Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("QSOs by Mode")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if !analytics.qsosByMode.isEmpty {
                            if #available(iOS 17.0, *) {
                                Chart {
                                    ForEach(Array(analytics.qsosByMode.sorted(by: { $0.value > $1.value }).prefix(8)), id: \.key) { mode, count in
                                        SectorMark(
                                            angle: .value("Count", count),
                                            innerRadius: .ratio(0.5),
                                            angularInset: 2
                                        )
                                        .foregroundStyle(by: .value("Mode", mode))
                                    }
                                }
                                .frame(height: 200)
                                .padding(.horizontal)
                            } else {
                                // iOS 16 fallback: horizontal bars by mode
                                Chart {
                                    ForEach(Array(analytics.qsosByMode.sorted(by: { $0.value > $1.value }).prefix(8)), id: \.key) { mode, count in
                                        BarMark(
                                            x: .value("Count", count),
                                            y: .value("Mode", mode)
                                        )
                                        .foregroundStyle(Color.orange.gradient)
                                    }
                                }
                                .frame(height: 200)
                                .padding(.horizontal)
                            }
                        } else {
                            EmptyChartView(message: "No QSOs logged yet")
                        }
                    }
                    
                    // MARK: - Recent Activity
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Activity (Last 30 Days)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if !analytics.qsosByDay.isEmpty {
                            Chart {
                                ForEach(Array(analytics.qsosByDay.sorted(by: { $0.key < $1.key })), id: \.key) { date, count in
                                    LineMark(
                                        x: .value("Date", date, unit: .day),
                                        y: .value("QSOs", count)
                                    )
                                    .foregroundStyle(Color.green.gradient)
                                    .interpolationMethod(.catmullRom)
                                    
                                    AreaMark(
                                        x: .value("Date", date, unit: .day),
                                        y: .value("QSOs", count)
                                    )
                                    .foregroundStyle(Color.green.opacity(0.1).gradient)
                                }
                            }
                            .frame(height: 200)
                            .padding(.horizontal)
                        } else {
                            EmptyChartView(message: "No recent activity")
                        }
                    }
                    
                    // MARK: - QSL Statistics
                    VStack(alignment: .leading, spacing: 16) {
                        Text("QSL Statistics")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            QSLStatCard(
                                title: "Sent",
                                count: analytics.qslSentCount,
                                total: analytics.totalQSOs,
                                color: .green
                            )
                            
                            QSLStatCard(
                                title: "Received",
                                count: analytics.qslReceivedCount,
                                total: analytics.totalQSOs,
                                color: .blue
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Top Bands
                    if !analytics.qsosByBand.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Top Bands")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 8) {
                                ForEach(Array(analytics.qsosByBand.sorted(by: { $0.value > $1.value }).prefix(5)), id: \.key) { band, count in
                                    TopBandRow(band: band, count: count, total: analytics.totalQSOs)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // MARK: - Top Modes
                    if !analytics.qsosByMode.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Top Modes")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 8) {
                                ForEach(Array(analytics.qsosByMode.sorted(by: { $0.value > $1.value }).prefix(5)), id: \.key) { mode, count in
                                    TopModeRow(mode: mode, count: count, total: analytics.totalQSOs)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Analytics Available")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Log some QSOs to see your statistics")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.large)
        .background(AppTheme.groupBackground)
        .refreshable {
            qsoViewModel.loadQSOs()
        }
    }
}

// MARK: - Analytics Card
struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
    }
}

// MARK: - QSL Stat Card
struct QSLStatCard: View {
    let title: String
    let count: Int
    let total: Int
    let color: Color
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total) * 100
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text("\(Int(percentage))%")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressView(value: percentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
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

// MARK: - Top Band Row
struct TopBandRow: View {
    let band: String
    let count: Int
    let total: Int
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total) * 100
    }
    
    var body: some View {
        HStack {
            Text(band)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Text("\(count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("(\(Int(percentage))%)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Top Mode Row
struct TopModeRow: View {
    let mode: String
    let count: Int
    let total: Int
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total) * 100
    }
    
    var body: some View {
        HStack {
            Text(mode)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Text("\(count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("(\(Int(percentage))%)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty Chart View
struct EmptyChartView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar")
                .font(.title)
                .foregroundColor(.secondary)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
}

#Preview {
    NavigationView {
        AnalyticsView()
            .environmentObject(QSOViewModel(context: PersistenceController.preview.container.viewContext))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
