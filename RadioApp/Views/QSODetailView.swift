//
//  QSODetailView.swift
//  RadioApp
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//

import SwiftUI

struct QSODetailView: View {
    @EnvironmentObject var qsoViewModel: QSOViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    let qso: QSO
    @State private var isEditing = false
    @State private var qsoData = QSOData()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Header
                    VStack(spacing: 8) {
                        Text(qso.callsign ?? "Unknown")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("\(qso.band ?? "") \(qso.mode ?? "")")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text(qso.datetime?.formatted(date: .complete, time: .shortened) ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // MARK: - Basic Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Basic Information")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            InfoRow(title: "Callsign", value: qso.callsign ?? "Unknown")
                            InfoRow(title: "Band", value: qso.band ?? "Unknown")
                            InfoRow(title: "Mode", value: qso.mode ?? "Unknown")
                            let freq = qso.frequencyMHz
                            if freq > 0 {
                                InfoRow(title: "Frequency", value: "\(String(format: "%.3f", freq)) MHz")
                            }
                            InfoRow(title: "RST Sent", value: qso.rstSent ?? "Unknown")
                            InfoRow(title: "RST Received", value: qso.rstReceived ?? "Unknown")
                            let power = qso.txPowerW
                            if power > 0 {
                                InfoRow(title: "Power", value: "\(Int(power))W")
                            }
                        }
                        .padding()
                        .cardStyle()
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Location Information
                    if qso.grid != nil || qso.dxcc != nil || qso.qth != nil {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Location")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                if let grid = qso.grid {
                                    InfoRow(title: "Grid", value: grid)
                                }
                                if let dxcc = qso.dxcc {
                                    InfoRow(title: "DXCC", value: dxcc)
                                }
                                if let qth = qso.qth {
                                    InfoRow(title: "QTH", value: qth)
                                }
                            }
                            .padding()
                            .cardStyle()
                            .padding(.horizontal)
                        }
                    }
                    
                    // MARK: - Equipment
                    if qso.rig != nil || qso.antenna != nil || qso.operatorCallsign != nil {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Equipment")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                if let rig = qso.rig {
                                    InfoRow(title: "Rig", value: rig)
                                }
                                if let antenna = qso.antenna {
                                    InfoRow(title: "Antenna", value: antenna)
                                }
                                if let operatorCallsign = qso.operatorCallsign {
                                    InfoRow(title: "Operator", value: operatorCallsign)
                                }
                            }
                            .padding()
                            .cardStyle()
                            .padding(.horizontal)
                        }
                    }
                    
                    // MARK: - Contest Information
                    if qso.contestName != nil || qso.serialSent != nil || qso.serialReceived != nil {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Contest Information")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                if let contestName = qso.contestName {
                                    InfoRow(title: "Contest", value: contestName)
                                }
                                let serialSent = qso.serialSent
                                if serialSent > 0 {
                                    InfoRow(title: "Serial Sent", value: "\(serialSent)")
                                }
                                let serialReceived = qso.serialReceived
                                if serialReceived > 0 {
                                    InfoRow(title: "Serial Received", value: "\(serialReceived)")
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
                    
                    // MARK: - QSL Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("QSL Status")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            QSLStatusRow(
                                title: "QSL Sent",
                                isSent: qso.qslSent,
                                date: qso.qslSentDate,
                                onToggle: {
                                    qsoViewModel.toggleQSLSent(qso)
                                }
                            )
                            
                            QSLStatusRow(
                                title: "QSL Received",
                                isSent: qso.qslReceived,
                                date: qso.qslReceivedDate,
                                onToggle: {
                                    qsoViewModel.toggleQSLReceived(qso)
                                }
                            )
                            
                            if let method = qso.qslMethod {
                                InfoRow(title: "QSL Method", value: method)
                            }
                        }
                        .padding()
                        .cardStyle()
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Notes
                    if let notes = qso.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Notes")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Text(notes)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cardStyle()
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("QSO Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        isEditing = true
                    }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            QSOEditView(qso: qso)
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
        }
    }
}

// MARK: - QSL Status Row
struct QSLStatusRow: View {
    let title: String
    let isSent: Bool
    let date: Date?
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Button(action: onToggle) {
                HStack(spacing: 8) {
                    Image(systemName: isSent ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSent ? .green : .secondary)
                    
                    Text(isSent ? "Yes" : "No")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if let date = date {
                Spacer()
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - QSO Edit View
struct QSOEditView: View {
    @EnvironmentObject var qsoViewModel: QSOViewModel
    @Environment(\.dismiss) private var dismiss
    
    let qso: QSO
    @State private var qsoData = QSOData()
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Basic Information
                Section("Basic Information") {
                    TextField("Callsign", text: Binding(
                        get: { qsoData.callsign ?? "" },
                        set: { qsoData.callsign = $0.isEmpty ? nil : $0 }
                    ))
                    .textInputAutocapitalization(.characters)
                    
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
                
                // MARK: - RST Reports
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
                
                // MARK: - Location
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
                
                // MARK: - Equipment
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
                }
                
                // MARK: - Contest
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
                }
                
                // MARK: - Notes
                Section("Notes") {
                    TextField("Notes", text: Binding(
                        get: { qsoData.notes ?? "" },
                        set: { qsoData.notes = $0.isEmpty ? nil : $0 }
                    ), axis: .vertical)
                    .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit QSO")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveQSO()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            loadQSOData()
        }
    }
    
    private func loadQSOData() {
        qsoData.datetime = qso.datetime
        qsoData.callsign = qso.callsign
        qsoData.band = qso.band
        qsoData.mode = qso.mode
        qsoData.frequencyMHz = qso.frequencyMHz
        qsoData.rstSent = qso.rstSent
        qsoData.rstReceived = qso.rstReceived
        qsoData.txPowerW = qso.txPowerW
        qsoData.operatorCallsign = qso.operatorCallsign
        qsoData.grid = qso.grid
        qsoData.dxcc = qso.dxcc
        qsoData.qth = qso.qth
        qsoData.rig = qso.rig
        qsoData.antenna = qso.antenna
        qsoData.contestName = qso.contestName
        qsoData.serialSent = qso.serialSent
        qsoData.serialReceived = qso.serialReceived
        qsoData.qsoDurationSec = qso.qsoDurationSec
        qsoData.notes = qso.notes
        qsoData.station = qso.station
    }
    
    private func saveQSO() {
        qsoViewModel.updateQSO(qso, with: qsoData)
        dismiss()
    }
}

#Preview {
    QSODetailView(qso: QSO())
        .environmentObject(QSOViewModel(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
