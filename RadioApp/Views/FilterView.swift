//
//  FilterView.swift
//  QSO Log app
//

import SwiftUI
import CoreData

struct FilterView: View {
    @EnvironmentObject var qsoViewModel: QSOViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedBand: String?
    @State private var selectedMode: String?
    @State private var selectedStation: StationProfile?
    @State private var dateRange: DateRange = .allTime
    @State private var qslFilter: QSLFilter = .all
    @State private var stations: [StationProfile] = []
   
    var body: some View {
        NavigationView {
            Form {
                Section("Band") {
                    Picker("Band", selection: $selectedBand) {
                        Text("All Bands").tag(nil as String?)
                        ForEach(BandCatalog.bandNames, id: \.self) { band in
                            Text(band).tag(band as String?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Mode") {
                    Picker("Mode", selection: $selectedMode) {
                        Text("All Modes").tag(nil as String?)
                        ForEach(ModeCatalog.modeNames, id: \.self) { mode in
                            Text(mode).tag(mode as String?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Station") {
                    Picker("Station", selection: $selectedStation) {
                        Text("All Stations").tag(nil as StationProfile?)
                        ForEach(stations, id: \.objectID) { station in
                            Text(station.name ?? "Unknown").tag(station as StationProfile?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Date Range") {
                    Picker("Date Range", selection: $dateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("QSL Status") {
                    Picker("QSL Status", selection: $qslFilter) {
                        ForEach(QSLFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    HStack {
                        Button("Clear All") { clearFilters() }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                        
                        Button("Apply Filters") { applyFilters() }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") { applyFilters() }
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            loadStations()
            loadCurrentFilters()
        }
    }
    
    private func loadStations() {
        let request: NSFetchRequest<StationProfile> = StationProfile.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \StationProfile.name, ascending: true)]
        do {
            stations = try viewContext.fetch(request)
        } catch {
            print("Failed to load stations: \(error)")
        }
    }
    
    private func loadCurrentFilters() {
        selectedBand = qsoViewModel.selectedBand
        selectedMode = qsoViewModel.selectedMode
        selectedStation = qsoViewModel.selectedStation
        dateRange = qsoViewModel.dateRange
        qslFilter = qsoViewModel.qslFilter
    }
    
    private func applyFilters() {
        qsoViewModel.selectedBand = selectedBand
        qsoViewModel.selectedMode = selectedMode
        qsoViewModel.selectedStation = selectedStation
        qsoViewModel.dateRange = dateRange
        qsoViewModel.qslFilter = qslFilter
        qsoViewModel.applyFilters()
        dismiss()
    }
    
    private func clearFilters() {
        selectedBand = nil
        selectedMode = nil
        selectedStation = nil
        dateRange = .allTime
        qslFilter = .all
    }
}

#Preview {
    NavigationView {
    FilterView()
        .environmentObject(QSOViewModel(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
}


