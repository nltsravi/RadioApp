//
//  BrowseLogsView.swift
//  RadioApp
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//

import SwiftUI

struct BrowseLogsView: View {
    @EnvironmentObject var qsoViewModel: QSOViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingFilters = false
    @State private var showingExport = false
    @State private var selectedQSO: QSO?
    @State private var showingQSODetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Search and Filter Bar
            VStack(spacing: 12) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search callsign, grid, DXCC...", text: $qsoViewModel.searchText)
                        .textFieldStyle(.plain)
                    
                    if !qsoViewModel.searchText.isEmpty {
                        Button(action: {
                            qsoViewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
                
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: "Band",
                            value: qsoViewModel.selectedBand,
                            onTap: { showingFilters = true }
                        )
                        
                        FilterChip(
                            title: "Mode",
                            value: qsoViewModel.selectedMode,
                            onTap: { showingFilters = true }
                        )
                        
                        FilterChip(
                            title: "Date",
                            value: qsoViewModel.dateRange.rawValue,
                            onTap: { showingFilters = true }
                        )
                        
                        FilterChip(
                            title: "QSL",
                            value: qsoViewModel.qslFilter.rawValue,
                            onTap: { showingFilters = true }
                        )
                        
                        if qsoViewModel.selectedStation != nil {
                            FilterChip(
                                title: "Station",
                                value: qsoViewModel.selectedStation?.name,
                                onTap: { showingFilters = true }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .background(AppTheme.groupBackground)
            
            // MARK: - QSO List
            if qsoViewModel.isLoading {
                Spacer()
                ProgressView("Loading QSOs...")
                Spacer()
            } else if qsoViewModel.filteredQSOs.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image(systemName: "radio")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No QSOs Found")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Try adjusting your search or filters")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding()
            } else {
                List {
                    ForEach(qsoViewModel.filteredQSOs, id: \.id) { qso in
                        QSOListView(qso: qso)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Edit") {
                                    selectedQSO = qso
                                    showingQSODetail = true
                                }
                                .tint(.blue)
                                
                                Button("Duplicate") {
                                    qsoViewModel.duplicateQSO(qso)
                                }
                                .tint(.orange)
                                
                                Button("Delete", role: .destructive) {
                                    qsoViewModel.deleteQSO(qso)
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button(qso.qslSent ? "QSL Sent ✓" : "Mark Sent") {
                                    qsoViewModel.toggleQSLSent(qso)
                                }
                                .tint(qso.qslSent ? .green : .blue)
                                
                                Button(qso.qslReceived ? "QSL Rcvd ✓" : "Mark Rcvd") {
                                    qsoViewModel.toggleQSLReceived(qso)
                                }
                                .tint(qso.qslReceived ? .green : .purple)
                            }
                            .onTapGesture {
                                selectedQSO = qso
                                showingQSODetail = true
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Browse Logs")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Filters") {
                    showingFilters = true
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Export ADIF") {
                        showingExport = true
                    }
                    
                    Button("Export CSV") {
                        // TODO: Implement CSV export
                    }
                    
                    Button("Clear Filters") {
                        clearFilters()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            FilterView()
        }
        .sheet(isPresented: $showingQSODetail) {
            if let qso = selectedQSO {
                QSODetailView(qso: qso)
            }
        }
        .sheet(isPresented: $showingExport) {
            ExportView()
        }
        .onChange(of: qsoViewModel.searchText) { _ in
            qsoViewModel.applyFilters()
        }
    }
    
    private func clearFilters() {
        qsoViewModel.searchText = ""
        qsoViewModel.selectedBand = nil
        qsoViewModel.selectedMode = nil
        qsoViewModel.selectedStation = nil
        qsoViewModel.dateRange = .allTime
        qsoViewModel.qslFilter = .all
        qsoViewModel.applyFilters()
    }
}

// MARK: - QSO List View
struct QSOListView: View {
    let qso: QSO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(qso.callsign ?? "Unknown")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(qso.band ?? "") \(qso.mode ?? "")")
                        .font(.subheadline)
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
            
            HStack {
                if let grid = qso.grid {
                    Text(grid)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
                
                if let dxcc = qso.dxcc {
                    Text(dxcc)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }
                
                if let qth = qso.qth {
                    Text(qth)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                let power = qso.txPowerW
                if power > 0 {
                    Text("\(Int(power))W")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let notes = qso.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let value: String?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if let value = value {
                    Text(value)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(value != nil ? Color.blue.opacity(0.1) : Color(.systemGray5))
            )
            .foregroundColor(value != nil ? .blue : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        BrowseLogsView()
            .environmentObject(QSOViewModel(context: PersistenceController.preview.container.viewContext))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
