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
    @Environment(\.openURL) private var openURL
    
    @State private var showingStationProfiles = false
    @State private var showingBandModeSettings = false
    @State private var showingImportExport = false
    @State private var showingAbout = false
    @State private var showingResetData = false
    
    private let privacyPolicyURL = URL(string: "https://example.com/privacy")!
    private let termsURL = URL(string: "https://example.com/terms")!
    private var appVersion: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—" }
    private var buildNumber: String { Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—" }
    
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
                    showingResetData = true
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
                
                Button(action: { openURL(privacyPolicyURL) }) {
                    SettingsRow(
                        icon: "hand.raised",
                        title: "Privacy Policy",
                        subtitle: "Read how we handle your data",
                        color: .purple
                    )
                }
                
                Button(action: { openURL(termsURL) }) {
                    SettingsRow(
                        icon: "doc.text",
                        title: "Terms & Conditions",
                        subtitle: "Usage terms and legal information",
                        color: .orange
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
                
                // App Version (read-only row)
                SettingsRow(
                    icon: "number.square",
                    title: "App Version",
                    subtitle: "Version \(appVersion) (Build \(buildNumber))",
                    color: .gray
                )
            } header: {
                Text("About & Support")
            }
        }
        .sheet(isPresented: $showingResetData) {
            ResetDataView()
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
                    .foregroundColor(.primary)
                
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
    @State private var showingImportAlert = false
    @State private var showingImportPreview = false
    @State private var importMessage = ""
    @State private var selectedImportFile: URL?
    @State private var importPreviewData: ImportPreviewData?
    @State private var isImporting = false
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Import/Export QSOs")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Import QSOs from ADIF files or export your log in various formats.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            Section("Export") {
                NavigationLink(destination: ExportView()) {
                    SettingsRow(
                        icon: "square.and.arrow.up",
                        title: "Export QSOs",
                        subtitle: "Export to ADIF or CSV format",
                        color: .blue
                    )
                }
            }
            
            Section("Import") {
                Button(action: {
                    showingImportPicker = true
                }) {
                    SettingsRow(
                        icon: "square.and.arrow.down",
                        title: "Import from ADIF",
                        subtitle: "Import QSOs from ADIF file",
                        color: .green
                    )
                }
                
                if let previewData = importPreviewData {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Import Preview")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("File: \(previewData.filename)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("QSOs found: \(previewData.qsoCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if previewData.hasErrors {
                            Text("⚠️ File contains validation errors")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        HStack {
                            Button("Import") {
                                importADIFFile(from: selectedImportFile!)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isImporting)
                            
                            Button("Cancel") {
                                importPreviewData = nil
                                selectedImportFile = nil
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Section("Data Management") {
                Button(action: {
                    // TODO: Implement backup
                }) {
                    SettingsRow(
                        icon: "icloud.and.arrow.up",
                        title: "Backup to iCloud",
                        subtitle: "Create backup of your QSO log",
                        color: .blue
                    )
                }
                
                Button(action: {
                    // TODO: Implement restore
                }) {
                    SettingsRow(
                        icon: "icloud.and.arrow.down",
                        title: "Restore from iCloud",
                        subtitle: "Restore QSO log from backup",
                        color: .orange
                    )
                }
            }
        }
        .navigationTitle("Import/Export")
        .navigationBarTitleDisplayMode(.large)
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    selectedImportFile = url
                    previewADIFFile(from: url)
                }
            case .failure(let error):
                importMessage = "Import failed: \(error.localizedDescription)"
                showingImportAlert = true
            }
        }
        .alert("Import Result", isPresented: $showingImportAlert) {
            Button("OK") { }
        } message: {
            Text(importMessage)
        }
        .sheet(isPresented: $showingImportPreview) {
            ImportPreviewView(previewData: importPreviewData!) {
                importADIFFile(from: selectedImportFile!)
            }
        }
    }
    
    private func previewADIFFile(from url: URL) {
        do {
            let content = try String(contentsOf: url)
            let result = qsoViewModel.previewADIFImport(content)
            importPreviewData = ImportPreviewData(
                filename: url.lastPathComponent,
                qsoCount: result.importedCount,
                hasErrors: result.errorCount > 0,
                errorCount: result.errorCount,
                warningCount: result.warnings.count,
                duplicateCount: result.duplicateCount
            )
        } catch {
            importMessage = "Failed to read ADIF file: \(error.localizedDescription)"
            showingImportAlert = true
        }
    }
    
    private func importADIFFile(from url: URL) {
        isImporting = true
        
        do {
            let content = try String(contentsOf: url)
            qsoViewModel.importFromADIF(content)
            importMessage = "ADIF file imported successfully"
            showingImportAlert = true
            
            // Clear preview data after successful import
            importPreviewData = nil
            selectedImportFile = nil
        } catch {
            importMessage = "Failed to read ADIF file: \(error.localizedDescription)"
            showingImportAlert = true
        }
        
        isImporting = false
    }
}

// MARK: - Import Preview Data
struct ImportPreviewData {
    let filename: String
    let qsoCount: Int
    let hasErrors: Bool
    let errorCount: Int
    let warningCount: Int
    let duplicateCount: Int
}

// MARK: - Import Preview View
struct ImportPreviewView: View {
    let previewData: ImportPreviewData
    let onImport: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "doc.text")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text(previewData.filename)
                                    .font(.headline)
                                Text("ADIF Import Preview")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        ImportPreviewRow(
                            icon: "number.circle",
                            title: "QSOs Found",
                            value: "\(previewData.qsoCount)",
                            color: .green
                        )
                        
                        if previewData.duplicateCount > 0 {
                            ImportPreviewRow(
                                icon: "exclamationmark.triangle",
                                title: "Potential Duplicates",
                                value: "\(previewData.duplicateCount)",
                                color: .orange
                            )
                        }
                        
                        if previewData.errorCount > 0 {
                            ImportPreviewRow(
                                icon: "xmark.circle",
                                title: "Validation Errors",
                                value: "\(previewData.errorCount)",
                                color: .red
                            )
                        }
                        
                        if previewData.warningCount > 0 {
                            ImportPreviewRow(
                                icon: "exclamationmark.triangle",
                                title: "Warnings",
                                value: "\(previewData.warningCount)",
                                color: .yellow
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    if previewData.hasErrors {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("⚠️ Import Issues Detected")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                            
                            Text("This file contains validation errors. Some QSOs may not import correctly. Review the import results after completion.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("✅ File Ready for Import")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                            
                            Text("The file appears to be valid and ready for import.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Import Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Import") {
                        onImport()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(previewData.qsoCount == 0)
                }
            }
        }
    }
}

// MARK: - Import Preview Row
struct ImportPreviewRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

// MARK: - Export View
struct ExportView: View {
    @EnvironmentObject var qsoViewModel: QSOViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isExporting = false
    @State private var exportProgress = 0.0
    @State private var showingExportSuccess = false
    @State private var exportMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Export QSOs")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Export your QSO log in various formats for use with other logging software or backup purposes.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Export Format") {
                    ExportOptionRow(
                        icon: "doc.text",
                        title: "ADIF Format",
                        subtitle: "Standard format for amateur radio logging",
                        color: .blue
                    ) {
                        exportADIF()
                    }
                    
                    ExportOptionRow(
                        icon: "tablecells",
                        title: "CSV Format",
                        subtitle: "Comma-separated values for spreadsheet import",
                        color: .green
                    ) {
                        exportCSV()
                    }
                }
                
                Section("Export Options") {
                    ExportOptionRow(
                        icon: "square.and.arrow.up",
                        title: "Export All QSOs",
                        subtitle: "Export your complete QSO log",
                        color: .orange
                    ) {
                        exportAllQSOs()
                    }
                    
                    ExportOptionRow(
                        icon: "line.3.horizontal.decrease.circle",
                        title: "Export Filtered QSOs",
                        subtitle: "Export only currently filtered QSOs",
                        color: .purple
                    ) {
                        exportFilteredQSOs()
                    }
                }
                
                if isExporting {
                    Section {
                        VStack(spacing: 12) {
                            ProgressView(value: exportProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                            
                            Text("Exporting QSOs...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Export Complete", isPresented: $showingExportSuccess) {
                Button("OK") { }
            } message: {
                Text(exportMessage)
            }
        }
    }
    
    private func exportADIF() {
        isExporting = true
        exportProgress = 0.3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exportProgress = 0.7
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                exportProgress = 1.0
                isExporting = false
                exportAllQSOs()
            }
        }
    }
    
    private func exportCSV() {
        isExporting = true
        exportProgress = 0.3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exportProgress = 0.7
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                exportProgress = 1.0
                isExporting = false
                exportAllQSOsAsCSV()
            }
        }
    }
    
    private func exportAllQSOs() {
        let adifContent = qsoViewModel.exportToADIF()
        let filename = "qsolog_all_\(formatDate(Date())).adi"
        shareContent(adifContent, filename: filename, contentType: "text/plain")
    }
    
    private func exportFilteredQSOs() {
        let adifContent = qsoViewModel.exportToADIF()
        let filename = "qsolog_filtered_\(formatDate(Date())).adi"
        shareContent(adifContent, filename: filename, contentType: "text/plain")
    }
    
    private func exportAllQSOsAsCSV() {
        let csvContent = qsoViewModel.exportToCSV()
        let filename = "qsolog_all_\(formatDate(Date())).csv"
        shareContent(csvContent, filename: filename, contentType: "text/csv")
    }
    
    private func exportFilteredQSOsAsCSV() {
        let csvContent = qsoViewModel.exportToCSV()
        let filename = "qsolog_filtered_\(formatDate(Date())).csv"
        shareContent(csvContent, filename: filename, contentType: "text/csv")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: date)
    }
    
    private func shareContent(_ content: String, filename: String, contentType: String) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try content.write(to: tempURL, atomically: true, encoding: .utf8)
            
            let activityVC = UIActivityViewController(
                activityItems: [tempURL],
                applicationActivities: nil
            )
            
            // Set the content type for better sharing
            activityVC.setValue(contentType, forKey: "contentType")
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(activityVC, animated: true)
                
                // Show success message
                exportMessage = "Successfully exported \(filename)"
                showingExportSuccess = true
            }
        } catch {
            exportMessage = "Failed to create export file: \(error.localizedDescription)"
            showingExportSuccess = true
        }
    }
}

// MARK: - Export Option Row
struct ExportOptionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - About View
struct AboutView: View {
    private var appVersion: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—" }
    private var buildNumber: String { Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—" }
    
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
                    
                    Text("Version \(appVersion) (Build \(buildNumber))")
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

// MARK: - Reset Data View
struct ResetDataView: View {
    @EnvironmentObject var qsoViewModel: QSOViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingConfirmation = false
    @State private var showingExportSheet = false
    @State private var isResetting = false
    @State private var resetSuccess = false
    
    private var dataStats: DataStatistics {
        qsoViewModel.getDataStatistics()
    }
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Warning Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            
                            Text("⚠️ This action cannot be undone")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                        
                        Text("Resetting data will permanently delete all your QSOs, station profiles, and settings. This action cannot be reversed.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - Data Statistics
                if dataStats.hasData {
                    Section("Current Data") {
                        DataStatRow(
                            icon: "radio.fill",
                            title: "QSOs",
                            value: "\(dataStats.qsoCount)",
                            color: .blue
                        )
                        
                        DataStatRow(
                            icon: "antenna.radiowaves.left.and.right",
                            title: "Station Profiles",
                            value: "\(dataStats.stationCount)",
                            color: .green
                        )
                        
                        DataStatRow(
                            icon: "person.2.fill",
                            title: "Unique Callsigns",
                            value: "\(dataStats.uniqueCallsigns)",
                            color: .purple
                        )
                        
                        DataStatRow(
                            icon: "calendar",
                            title: "Date Range",
                            value: dataStats.dateRangeText,
                            color: .orange
                        )
                    }
                    
                    // MARK: - Export Suggestion
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("💡 Export your data first")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("Before resetting, consider exporting your QSOs to ADIF or CSV format. You can import them back later if needed.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                showingExportSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Export Data Now")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // MARK: - Reset Options
                Section {
                    Button(action: {
                        showingConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                            
                            Text("Reset All Data")
                                .foregroundColor(.red)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                    }
                    .disabled(isResetting)
                } header: {
                    Text("Reset Options")
                } footer: {
                    Text("This will delete all QSOs, station profiles (except default), and reset all settings to factory defaults.")
                }
            }
            .navigationTitle("Reset Data")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Confirm Reset", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset All Data", role: .destructive) {
                performReset()
            }
        } message: {
            Text("Are you sure you want to permanently delete all your QSO data? This action cannot be undone.")
        }
        .alert("Reset Complete", isPresented: $resetSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("All data has been successfully reset. The app will now show a clean state.")
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportView()
        }
    }
    
    private func performReset() {
        isResetting = true
        
        // Simulate a brief delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let success = qsoViewModel.resetAllData()
            isResetting = false
            
            if success {
                resetSuccess = true
            }
        }
    }
}

// MARK: - Data Stat Row
struct DataStatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(QSOViewModel(context: PersistenceController.preview.container.viewContext))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
