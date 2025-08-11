//
//  FullLogView.swift
//  RadioApp
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//

import SwiftUI
import CoreData

struct FullLogView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var qsoData: QSOData
    let onSave: () -> Void
    
    @State private var stations: [StationProfile] = []
    @State private var showingStationPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                basicInformationSection
                rstReportsSection
                locationSection
                equipmentSection
                contestSection
                qslSection
                notesSection
            }
            .navigationTitle("Log QSO")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingStationPicker) {
            StationPickerView(selectedStation: $qsoData.station, stations: stations)
        }
        .onAppear {
            loadStations()
        }
    }
    
    private var basicInformationSection: some View {
        Section("Basic Information") {
            TextField("Callsign", text: Binding(
                get: { qsoData.callsign ?? "" },
                set: { qsoData.callsign = $0.isEmpty ? nil : $0 }
            ))
            .textInputAutocapitalization(.characters)
            
            DatePicker("Date & Time", selection: Binding(
                get: { qsoData.datetime ?? Date() },
                set: { qsoData.datetime = $0 }
            ), displayedComponents: [.date, .hourAndMinute])
            
            Picker("Band", selection: Binding(
                get: { qsoData.band ?? "" },
                set: { qsoData.band = $0 }
            )) {
                ForEach(BandCatalog.bandNames, id: \.self) { band in
                    Text(band).tag(band)
                }
            }
            
            Picker("Mode", selection: Binding(
                get: { qsoData.mode ?? "" },
                set: { qsoData.mode = $0 }
            )) {
                ForEach(ModeCatalog.modeNames, id: \.self) { mode in
                    Text(mode).tag(mode)
                }
            }
            
            HStack {
                Text("Frequency (MHz)")
                Spacer()
                TextField("0.000", value: $qsoData.frequencyMHz, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
    
        private var rstReportsSection: some View {
        Section("RST Reports") {
            TextField("RST Sent", text: Binding(
                get: { qsoData.rstSent ?? "" },
                set: { qsoData.rstSent = $0.isEmpty ? nil : $0 }
            ))
            
            TextField("RST Received", text: Binding(
                get: { qsoData.rstReceived ?? "" },
                set: { qsoData.rstReceived = $0.isEmpty ? nil : $0 }
            ))
            
            HStack {
                Text("Power (W)")
                Spacer()
                TextField("0", value: $qsoData.txPowerW, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
    
        private var locationSection: some View {
        Section("Location") {
            TextField("Grid Square", text: Binding(
                get: { qsoData.grid ?? "" },
                set: { qsoData.grid = $0.isEmpty ? nil : $0 }
            ))
            .textInputAutocapitalization(.characters)
            
            TextField("DXCC", text: Binding(
                get: { qsoData.dxcc ?? "" },
                set: { qsoData.dxcc = $0.isEmpty ? nil : $0 }
            ))
            
            TextField("QTH", text: Binding(
                get: { qsoData.qth ?? "" },
                set: { qsoData.qth = $0.isEmpty ? nil : $0 }
            ))
        }
    }
    
    private var equipmentSection: some View {
        Section("Equipment") {
            TextField("Rig", text: Binding(
                get: { qsoData.rig ?? "" },
                set: { qsoData.rig = $0.isEmpty ? nil : $0 }
            ))
            
            TextField("Antenna", text: Binding(
                get: { qsoData.antenna ?? "" },
                set: { qsoData.antenna = $0.isEmpty ? nil : $0 }
            ))
            
            TextField("Operator", text: Binding(
                get: { qsoData.operatorCallsign ?? "" },
                set: { qsoData.operatorCallsign = $0.isEmpty ? nil : $0 }
            ))
            .textInputAutocapitalization(.characters)
            
            Button(action: {
                loadStations()
                showingStationPicker = true
            }) {
                HStack {
                    Text("Station Profile")
                        .foregroundColor(qsoData.station == nil ? .secondary : .primary)
                    Spacer()
                    Text(qsoData.station?.name ?? "Select Station")
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var contestSection: some View {
        Section("Contest") {
            TextField("Contest Name", text: Binding(
                get: { qsoData.contestName ?? "" },
                set: { qsoData.contestName = $0.isEmpty ? nil : $0 }
            ))
            
            HStack {
                Text("Serial Sent")
                Spacer()
                TextField("0", value: $qsoData.serialSent, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            
            HStack {
                Text("Serial Received")
                Spacer()
                TextField("0", value: $qsoData.serialReceived, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            
            HStack {
                Text("Duration (seconds)")
                Spacer()
                TextField("0", value: $qsoData.qsoDurationSec, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
    
    private var qslSection: some View {
        Section("QSL Information") {
            Text("QSL functionality will be added in a future update")
                .foregroundColor(.secondary)
        }
    }
    
    private var notesSection: some View {
        Section("Notes") {
            TextField("Notes", text: Binding(
                get: { qsoData.notes ?? "" },
                set: { qsoData.notes = $0.isEmpty ? nil : $0 }
            ), axis: .vertical)
            .lineLimit(3...6)
        }
    }
    
    private func loadStations() {
        let request: NSFetchRequest<StationProfile> = StationProfile.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \StationProfile.name, ascending: true)]
        
        do {
            stations = try viewContext.fetch(request)
            if stations.isEmpty {
                // Seed default stations if none exist
                let defaults: [(String, String, String, Double, Bool)] = [
                    ("Home", "20m", "SSB", 100.0, true),
                    ("Portable", "40m", "CW", 50.0, false),
                    ("Mobile", "2m", "FM", 25.0, false)
                ]
                for (name, band, mode, power, isDefault) in defaults {
                    let s = StationProfile(context: viewContext)
                    s.id = UUID()
                    s.name = name
                    s.defaultBand = band
                    s.defaultMode = mode
                    s.defaultPowerW = power
                    s.isDefault = isDefault
                }
                try viewContext.save()
                stations = try viewContext.fetch(request)
                if qsoData.station == nil {
                    qsoData.station = stations.first(where: { $0.isDefault }) ?? stations.first
                }
            }
        } catch {
            print("Failed to load stations: \(error)")
        }
    }
}

#Preview {
    FullLogView(qsoData: .constant(QSOData()), onSave: {})
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
