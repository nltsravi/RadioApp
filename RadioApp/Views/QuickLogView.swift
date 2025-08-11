//
//  QuickLogView.swift
//  RadioApp
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//

import SwiftUI
import CoreData

struct QuickLogView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var callsign: String
    @Binding var band: String
    @Binding var mode: String
    @Binding var rstSent: String
    @Binding var rstReceived: String
    @Binding var power: Double
    @Binding var station: StationProfile?
    
    let onSave: () -> Void
    
    @State private var showingStationPicker = false
    @State private var stations: [StationProfile] = []
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Callsign Section
                Section("Callsign") {
                    TextField("Callsign", text: $callsign)
                        .textInputAutocapitalization(.characters)
                        .onChange(of: callsign) { newValue in
                            callsign = newValue.uppercased()
                        }
                }
                
                // MARK: - Band & Mode Section
                Section("Band & Mode") {
                    HStack {
                        Picker("Band", selection: $band) {
                            ForEach(BandCatalog.bandNames, id: \.self) { bandName in
                                Text(bandName).tag(bandName)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Divider()
                        
                        Picker("Mode", selection: $mode) {
                            ForEach(ModeCatalog.modeNames, id: \.self) { modeName in
                                Text(modeName).tag(modeName)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                // MARK: - RST Section
                Section("RST Reports") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Sent")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Picker("RST Sent", selection: $rstSent) {
                                ForEach(RSTScale.readability, id: \.self) { r in
                                    ForEach(RSTScale.strength, id: \.self) { s in
                                        Text("\(r)\(s)").tag("\(r)\(s)")
                                    }
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading) {
                            Text("Received")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Picker("RST Received", selection: $rstReceived) {
                                ForEach(RSTScale.readability, id: \.self) { r in
                                    ForEach(RSTScale.strength, id: \.self) { s in
                                        Text("\(r)\(s)").tag("\(r)\(s)")
                                    }
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                }
                
                // MARK: - Power Section
                Section("Power (Watts)") {
                    HStack {
                        Slider(value: $power, in: 1...1500, step: 1)
                        Text("\(Int(power))W")
                            .font(.headline)
                            .frame(width: 60)
                    }
                }
                
                // MARK: - Station Section
                Section("Station") {
                    Button(action: {
                        loadStations()
                        showingStationPicker = true
                    }) {
                        HStack {
                            Text(station?.name ?? "Select Station")
                                .foregroundColor(station == nil ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // MARK: - Quick Actions
                Section {
                    HStack(spacing: 12) {
                        Button("Save & New") { onSave() }
                            .buttonStyle(PrimaryActionButtonStyle())

                        Button("Cancel") { dismiss() }
                            .buttonStyle(SecondaryActionButtonStyle())
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Quick Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingStationPicker) {
            StationPickerView(selectedStation: $station, stations: stations)
        }
        .onAppear {
            loadStations()
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
            }
            // Ensure a selection is set if none exists yet
            if station == nil {
                station = stations.first(where: { $0.isDefault }) ?? stations.first
            }
        } catch {
            print("Failed to load stations: \(error)")
        }
    }
}

// MARK: - Station Picker View
struct StationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedStation: StationProfile?
    let stations: [StationProfile]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(stations, id: \.objectID) { station in
                    Button(action: {
                        selectedStation = station
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(station.name ?? "Unknown")
                                    .font(.headline)
                                
                                if let operatorCallsign = station.operatorCallsign {
                                    Text(operatorCallsign)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let rig = station.rig {
                                    Text(rig)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if selectedStation?.id == station.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Select Station")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    QuickLogView(
        callsign: .constant(""),
        band: .constant("20m"),
        mode: .constant("SSB"),
        rstSent: .constant("59"),
        rstReceived: .constant("59"),
        power: .constant(100.0),
        station: .constant(nil),
        onSave: {}
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
