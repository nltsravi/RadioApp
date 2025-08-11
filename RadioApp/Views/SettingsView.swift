//
//  SettingsView.swift
//  RadioApp
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @EnvironmentObject var qsoViewModel: QSOViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingStationProfiles = false
    @State private var showingBandModeSettings = false
    @State private var showingImportExport = false
    @State private var showingAbout = false
    
    var body: some View {
        List {
            // MARK: - Station Profiles
            Section {
                NavigationLink(destination: StationProfilesView()) {
                    SettingsRow(
                        icon: "antenna.radiowaves.left.and.right",
                        title: "Station Profiles",
                        subtitle: "Manage your station configurations",
                        color: .blue
                    )
                }
                
                NavigationLink(destination: BandModeSettingsView()) {
                    SettingsRow(
                        icon: "slider.horizontal.3",
                        title: "Bands & Modes",
                        subtitle: "Configure available bands and modes",
                        color: .green
                    )
                }
            } header: {
                Text("Configuration")
            }
            
            // MARK: - Data Management
            Section {
                NavigationLink(destination: ImportExportView()) {
                    SettingsRow(
                        icon: "square.and.arrow.up.on.square",
                        title: "Import/Export",
                        subtitle: "ADIF import/export and data backup",
                        color: .orange
                    )
                }
                
                Button(action: {
                    // TODO: Implement data reset
                }) {
                    SettingsRow(
                        icon: "trash",
                        title: "Reset Data",
                        subtitle: "Clear all QSOs and settings",
                        color: .red
                    )
                }
            } header: {
                Text("Data Management")
            }
            
            // MARK: - Privacy & Sync
            Section {
                Toggle(isOn: .constant(false)) {
                    SettingsRow(
                        icon: "icloud",
                        title: "iCloud Sync",
                        subtitle: "Sync data across devices",
                        color: .blue
                    )
                }
                
                Toggle(isOn: .constant(true)) {
                    SettingsRow(
                        icon: "lock.shield",
                        title: "Local Only",
                        subtitle: "Keep data on device only",
                        color: .purple
                    )
                }
            } header: {
                Text("Privacy & Sync")
            }
            
            // MARK: - App Settings
            Section {
                Toggle(isOn: .constant(true)) {
                    SettingsRow(
                        icon: "iphone.radiowaves.left.and.right",
                        title: "Haptic Feedback",
                        subtitle: "Vibrate on QSO save",
                        color: .green
                    )
                }
                
                Toggle(isOn: .constant(true)) {
                    SettingsRow(
                        icon: "speaker.wave.2",
                        title: "Sound Effects",
                        subtitle: "Play sounds for actions",
                        color: .orange
                    )
                }
            } header: {
                Text("App Settings")
            }
            
            // MARK: - About & Support
            Section {
                NavigationLink(destination: AboutView()) {
                    SettingsRow(
                        icon: "info.circle",
                        title: "About QSO Log",
                        subtitle: "Version and app information",
                        color: .blue
                    )
                }
                
                Button(action: {
                    // TODO: Implement feedback
                }) {
                    SettingsRow(
                        icon: "envelope",
                        title: "Send Feedback",
                        subtitle: "Report bugs or suggest features",
                        color: .green
                    )
                }
                
                Button(action: {
                    // TODO: Implement rate app
                }) {
                    SettingsRow(
                        icon: "star",
                        title: "Rate App",
                        subtitle: "Rate QSO Log on App Store",
                        color: .yellow
                    )
                }
            } header: {
                Text("About & Support")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .background(AppTheme.groupBackground)
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Station Profiles View
struct StationProfilesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StationProfile.name, ascending: true)],
        animation: .default)
    private var stations: FetchedResults<StationProfile>
    
    @State private var showingAddStation = false
    @State private var editingStation: StationProfile?
    
    var body: some View {
        List {
            ForEach(stations) { station in
                StationProfileRow(station: station) {
                    editingStation = station
                }
            }
            .onDelete(perform: deleteStations)
        }
        .navigationTitle("Station Profiles")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    showingAddStation = true
                }
            }
        }
        .sheet(isPresented: $showingAddStation) {
            StationProfileEditView(station: nil)
        }
        .sheet(item: $editingStation) { station in
            StationProfileEditView(station: station)
        }
    }
    
    private func deleteStations(offsets: IndexSet) {
        withAnimation {
            offsets.map { stations[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete station: \(error)")
            }
        }
    }
}

// MARK: - Station Profile Row
struct StationProfileRow: View {
    let station: StationProfile
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(station.name ?? "Unknown")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if station.isDefault {
                        Text("Default")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
                
                if let operatorCallsign = station.operatorCallsign {
                    Text(operatorCallsign)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let rig = station.rig {
                    Text(rig)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Station Profile Edit View
struct StationProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    let station: StationProfile?
    
    @State private var name = ""
    @State private var operatorCallsign = ""
    @State private var rig = ""
    @State private var antenna = ""
    @State private var defaultBand = "20m"
    @State private var defaultMode = "SSB"
    @State private var defaultPower = 100.0
    @State private var isDefault = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Station Name", text: $name)
                    TextField("Operator Callsign", text: $operatorCallsign)
                        .textInputAutocapitalization(.characters)
                }
                
                Section("Equipment") {
                    TextField("Rig", text: $rig)
                    TextField("Antenna", text: $antenna)
                }
                
                Section("Defaults") {
                    Picker("Default Band", selection: $defaultBand) {
                        ForEach(BandCatalog.bandNames, id: \.self) { band in
                            Text(band).tag(band)
                        }
                    }
                    
                    Picker("Default Mode", selection: $defaultMode) {
                        ForEach(ModeCatalog.modeNames, id: \.self) { mode in
                            Text(mode).tag(mode)
                        }
                    }
                    
                    HStack {
                        Text("Default Power")
                        Spacer()
                        Text("\(Int(defaultPower))W")
                    }
                    
                    Slider(value: $defaultPower, in: 1...1500, step: 1)
                }
                
                Section {
                    Toggle("Set as Default Station", isOn: $isDefault)
                }
            }
            .navigationTitle(station == nil ? "New Station" : "Edit Station")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveStation()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            loadStationData()
        }
    }
    
    private func loadStationData() {
        guard let station = station else { return }
        
        name = station.name ?? ""
        operatorCallsign = station.operatorCallsign ?? ""
        rig = station.rig ?? ""
        antenna = station.antenna ?? ""
        defaultBand = station.defaultBand ?? "20m"
        defaultMode = station.defaultMode ?? "SSB"
        defaultPower = station.defaultPowerW
        isDefault = station.isDefault
    }
    
    private func saveStation() {
        let stationToSave = station ?? StationProfile(context: viewContext)
        
        if station == nil {
            stationToSave.id = UUID()
        }
        
        stationToSave.name = name
        stationToSave.operatorCallsign = operatorCallsign.uppercased()
        stationToSave.rig = rig
        stationToSave.antenna = antenna
        stationToSave.defaultBand = defaultBand
        stationToSave.defaultMode = defaultMode
        stationToSave.defaultPowerW = defaultPower
        stationToSave.isDefault = isDefault
        
        // If this is set as default, unset others
        if isDefault {
            let request: NSFetchRequest<StationProfile> = StationProfile.fetchRequest()
            request.predicate = NSPredicate(format: "isDefault == YES")
            
            do {
                let defaultStations = try viewContext.fetch(request)
                for defaultStation in defaultStations {
                    if defaultStation != stationToSave {
                        defaultStation.isDefault = false
                    }
                }
            } catch {
                print("Failed to update default stations: \(error)")
            }
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save station: \(error)")
        }
    }
}

// MARK: - Band Mode Settings View
struct BandModeSettingsView: View {
    var body: some View {
        List {
            Section("Available Bands") {
                ForEach(BandCatalog.bandNames, id: \.self) { band in
                    HStack {
                        Text(band)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
            }
            
            Section("Available Modes") {
                ForEach(ModeCatalog.modeNames, id: \.self) { mode in
                    HStack {
                        Text(mode)
                        if let description = ModeCatalog.description(for: mode) {
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .navigationTitle("Bands & Modes")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Import Export View
struct ImportExportView: View {
    @EnvironmentObject var qsoViewModel: QSOViewModel
    @State private var showingImportPicker = false
    @State private var showingExportSheet = false
    
    var body: some View {
        List {
            Section("Export") {
                Button("Export to ADIF") {
                    showingExportSheet = true
                }
                
                Button("Export to CSV") {
                    // TODO: Implement CSV export
                }
            }
            
            Section("Import") {
                Button("Import from ADIF") {
                    showingImportPicker = true
                }
            }
        }
        .navigationTitle("Import/Export")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingExportSheet) {
            ExportView()
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    importADIFFile(from: url)
                }
            case .failure(let error):
                print("Import failed: \(error)")
            }
        }
    }
    
    private func importADIFFile(from url: URL) {
        do {
            let content = try String(contentsOf: url)
            qsoViewModel.importFromADIF(content)
        } catch {
            print("Failed to read ADIF file: \(error)")
        }
    }
}

// MARK: - Export View
struct ExportView: View {
    @EnvironmentObject var qsoViewModel: QSOViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Export QSOs")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Export your QSO log in ADIF format for use with other logging software.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Export All QSOs") {
                    exportAllQSOs()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Export Filtered QSOs") {
                    exportFilteredQSOs()
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export")
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
    
    private func exportAllQSOs() {
        let adifContent = qsoViewModel.exportToADIF()
        shareADIFContent(adifContent, filename: "qsolog_all.adi")
    }
    
    private func exportFilteredQSOs() {
        let adifContent = qsoViewModel.exportToADIF()
        shareADIFContent(adifContent, filename: "qsolog_filtered.adi")
    }
    
    private func shareADIFContent(_ content: String, filename: String) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try content.write(to: tempURL, atomically: true, encoding: .utf8)
            
            let activityVC = UIActivityViewController(
                activityItems: [tempURL],
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(activityVC, animated: true)
            }
        } catch {
            print("Failed to create export file: \(error)")
        }
    }
}

// MARK: - About View
struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "radio.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("QSO Log")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            
            Section("Features") {
                Text("• Fast QSO logging")
                Text("• ADIF import/export")
                Text("• Station profiles")
                Text("• Analytics and statistics")
                Text("• iCloud sync")
                Text("• Offline-first design")
            }
            
            Section("Privacy") {
                Text("QSO Log respects your privacy. All data is stored locally on your device and optionally synced to your private iCloud account.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(QSOViewModel(context: PersistenceController.preview.container.viewContext))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
