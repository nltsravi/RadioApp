//
//  QSOViewModel.swift
//  RadioApp
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//

import Foundation
import CoreData
import SwiftUI

@MainActor
class QSOViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    private let adifService: ADIFService
    
    @Published var qsos: [QSO] = []
    @Published var filteredQSOs: [QSO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // Filter properties
    @Published var searchText = ""
    @Published var selectedBand: String?
    @Published var selectedMode: String?
    @Published var selectedStation: StationProfile?
    @Published var dateRange: DateRange = .allTime
    @Published var qslFilter: QSLFilter = .all
    
    // Analytics
    @Published var analytics: QSOAnalytics?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.adifService = ADIFService(context: context)
        loadQSOs()
        ensureDefaultStationExists()
    }
    
    // MARK: - QSO Operations
    func addQSO(_ qsoData: QSOData) {
        let qso = QSO(context: context)
        qso.id = UUID()
        qso.datetime = qsoData.datetime ?? Date()
        qso.callsign = qsoData.callsign?.uppercased()
        qso.band = qsoData.band
        qso.mode = qsoData.mode
        qso.frequencyMHz = qsoData.frequencyMHz ?? 0.0
        qso.rstSent = qsoData.rstSent
        qso.rstReceived = qsoData.rstReceived
        qso.txPowerW = qsoData.txPowerW ?? 0.0
        qso.operatorCallsign = qsoData.operatorCallsign
        qso.grid = qsoData.grid
        qso.dxcc = qsoData.dxcc
        qso.qth = qsoData.qth
        qso.rig = qsoData.rig
        qso.antenna = qsoData.antenna
        qso.contestName = qsoData.contestName
        qso.serialSent = qsoData.serialSent ?? 0
        qso.serialReceived = qsoData.serialReceived ?? 0
        qso.qsoDurationSec = qsoData.qsoDurationSec ?? 0
        qso.notes = qsoData.notes
        qso.station = qsoData.station
        
        saveContext()
        loadQSOs()
    }
    
    func updateQSO(_ qso: QSO, with qsoData: QSOData) {
        qso.datetime = qsoData.datetime ?? qso.datetime
        qso.callsign = qsoData.callsign?.uppercased()
        qso.band = qsoData.band
        qso.mode = qsoData.mode
        qso.frequencyMHz = qsoData.frequencyMHz ?? qso.frequencyMHz
        qso.rstSent = qsoData.rstSent
        qso.rstReceived = qsoData.rstReceived
        qso.txPowerW = qsoData.txPowerW ?? qso.txPowerW
        qso.operatorCallsign = qsoData.operatorCallsign
        qso.grid = qsoData.grid
        qso.dxcc = qsoData.dxcc
        qso.qth = qsoData.qth
        qso.rig = qsoData.rig
        qso.antenna = qsoData.antenna
        qso.contestName = qsoData.contestName
        qso.serialSent = qsoData.serialSent ?? qso.serialSent
        qso.serialReceived = qsoData.serialReceived ?? qso.serialReceived
        qso.qsoDurationSec = qsoData.qsoDurationSec ?? qso.qsoDurationSec
        qso.notes = qsoData.notes
        qso.station = qsoData.station
        
        saveContext()
        loadQSOs()
    }
    
    func deleteQSO(_ qso: QSO) {
        context.delete(qso)
        saveContext()
        loadQSOs()
    }
    
    func duplicateQSO(_ qso: QSO) {
        let newQSO = QSO(context: context)
        newQSO.id = UUID()
        newQSO.datetime = Date()
        newQSO.callsign = qso.callsign
        newQSO.band = qso.band
        newQSO.mode = qso.mode
        newQSO.frequencyMHz = qso.frequencyMHz
        newQSO.rstSent = qso.rstSent
        newQSO.rstReceived = qso.rstReceived
        newQSO.txPowerW = qso.txPowerW
        newQSO.operatorCallsign = qso.operatorCallsign
        newQSO.grid = qso.grid
        newQSO.dxcc = qso.dxcc
        newQSO.qth = qso.qth
        newQSO.rig = qso.rig
        newQSO.antenna = qso.antenna
        newQSO.contestName = qso.contestName
        newQSO.serialSent = qso.serialSent
        newQSO.serialReceived = qso.serialReceived
        newQSO.qsoDurationSec = qso.qsoDurationSec
        newQSO.notes = qso.notes
        newQSO.station = qso.station
        
        saveContext()
        loadQSOs()
    }
    
    // MARK: - QSL Operations
    func toggleQSLSent(_ qso: QSO) {
        qso.qslSent.toggle()
        if qso.qslSent {
            qso.qslSentDate = Date()
        } else {
            qso.qslSentDate = nil
        }
        saveContext()
        loadQSOs()
    }
    
    func toggleQSLReceived(_ qso: QSO) {
        qso.qslReceived.toggle()
        if qso.qslReceived {
            qso.qslReceivedDate = Date()
        } else {
            qso.qslReceivedDate = nil
        }
        saveContext()
        loadQSOs()
    }
    
    // MARK: - Data Loading
    func loadQSOs() {
        isLoading = true
        
        let request: NSFetchRequest<QSO> = QSO.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \QSO.datetime, ascending: false)]
        
        do {
            qsos = try context.fetch(request)
            applyFilters()
            calculateAnalytics()
        } catch {
            showError(message: "Failed to load QSOs: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Filtering
    func applyFilters() {
        var filtered = qsos
        
        // Search text filter
        if !searchText.isEmpty {
            filtered = filtered.filter { qso in
                let callsign = qso.callsign?.lowercased() ?? ""
                let grid = qso.grid?.lowercased() ?? ""
                let dxcc = qso.dxcc?.lowercased() ?? ""
                let qth = qso.qth?.lowercased() ?? ""
                let searchLower = searchText.lowercased()
                
                return callsign.contains(searchLower) ||
                       grid.contains(searchLower) ||
                       dxcc.contains(searchLower) ||
                       qth.contains(searchLower)
            }
        }
        
        // Band filter
        if let selectedBand = selectedBand {
            filtered = filtered.filter { $0.band == selectedBand }
        }
        
        // Mode filter
        if let selectedMode = selectedMode {
            filtered = filtered.filter { $0.mode == selectedMode }
        }
        
        // Station filter
        if let selectedStation = selectedStation {
            filtered = filtered.filter { $0.station == selectedStation }
        }
        
        // Date range filter
        filtered = filtered.filter { qso in
            guard let datetime = qso.datetime else { return false }
            return dateRange.contains(datetime)
        }
        
        // QSL filter
        switch qslFilter {
        case .all:
            break
        case .sent:
            filtered = filtered.filter { $0.qslSent }
        case .received:
            filtered = filtered.filter { $0.qslReceived }
        case .pending:
            filtered = filtered.filter { !$0.qslSent || !$0.qslReceived }
        }
        
        filteredQSOs = filtered
    }
    
    // MARK: - Analytics
    func calculateAnalytics() {
        var analytics = QSOAnalytics()
        
        // Total QSOs
        analytics.totalQSOs = qsos.count
        
        // QSOs by band
        let bandCounts = Dictionary(grouping: qsos, by: { $0.band ?? "Unknown" })
            .mapValues { $0.count }
        analytics.qsosByBand = bandCounts
        
        // QSOs by mode
        let modeCounts = Dictionary(grouping: qsos, by: { $0.mode ?? "Unknown" })
            .mapValues { $0.count }
        analytics.qsosByMode = modeCounts
        
        // QSOs by day (last 30 days)
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentQSOs = qsos.filter { $0.datetime ?? Date() >= thirtyDaysAgo }
        
        let dayCounts = Dictionary(grouping: recentQSOs) { qso in
            calendar.startOfDay(for: qso.datetime ?? Date())
        }.mapValues { $0.count }
        analytics.qsosByDay = dayCounts
        
        // QSL statistics
        analytics.qslSentCount = qsos.filter { $0.qslSent }.count
        analytics.qslReceivedCount = qsos.filter { $0.qslReceived }.count
        
        // Unique callsigns
        let uniqueCallsigns = Set(qsos.compactMap { $0.callsign })
        analytics.uniqueCallsigns = uniqueCallsigns.count
        
        // DXCC entities
        let uniqueDXCC = Set(qsos.compactMap { $0.dxcc })
        analytics.dxccEntities = uniqueDXCC.count
        
        self.analytics = analytics
    }
    
    // MARK: - Export/Import
    func exportToADIF() -> String {
        return adifService.exportToADIF(qsos: filteredQSOs.isEmpty ? qsos : filteredQSOs)
    }
    
    func exportToCSV() -> String {
        let qsosToExport = filteredQSOs.isEmpty ? qsos : filteredQSOs
        
        // CSV Header
        var csvContent = "Date,Time,Callsign,Band,Mode,Frequency,RST Sent,RST Received,TX Power,Operator,Grid,DXCC,QTH,Rig,Antenna,Contest,Serial Sent,Serial Received,Duration,Notes,QSL Sent,QSL Received,QSL Sent Date,QSL Received Date,QSL Method\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        for qso in qsosToExport {
            var row: [String] = []
            
            // Date and Time
            if let datetime = qso.datetime {
                row.append(dateFormatter.string(from: datetime))
                row.append(timeFormatter.string(from: datetime))
            } else {
                row.append("")
                row.append("")
            }
            
            // Basic QSO info
            row.append(qso.callsign ?? "")
            row.append(qso.band ?? "")
            row.append(qso.mode ?? "")
            row.append(qso.frequencyMHz > 0 ? String(format: "%.6f", qso.frequencyMHz) : "")
            row.append(qso.rstSent ?? "")
            row.append(qso.rstReceived ?? "")
            row.append(qso.txPowerW > 0 ? String(format: "%.1f", qso.txPowerW) : "")
            row.append(qso.operatorCallsign ?? "")
            row.append(qso.grid ?? "")
            row.append(qso.dxcc ?? "")
            row.append(qso.qth ?? "")
            row.append(qso.rig ?? "")
            row.append(qso.antenna ?? "")
            row.append(qso.contestName ?? "")
            row.append(qso.serialSent > 0 ? String(qso.serialSent) : "")
            row.append(qso.serialReceived > 0 ? String(qso.serialReceived) : "")
            row.append(qso.qsoDurationSec > 0 ? String(qso.qsoDurationSec) : "")
            row.append(escapeCSVField(qso.notes ?? ""))
            
            // QSL info
            row.append(qso.qslSent ? "Y" : "N")
            row.append(qso.qslReceived ? "Y" : "N")
            row.append(qso.qslSentDate != nil ? dateFormatter.string(from: qso.qslSentDate!) : "")
            row.append(qso.qslReceivedDate != nil ? dateFormatter.string(from: qso.qslReceivedDate!) : "")
            row.append(qso.qslMethod ?? "")
            
            csvContent += row.joined(separator: ",") + "\n"
        }
        
        return csvContent
    }
    
    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }
    
    func importFromADIF(_ adifContent: String) {
        let result = adifService.importFromADIF(adifContent)
        
        // Build comprehensive import summary
        var summaryMessages: [String] = []
        
        if result.importedCount > 0 {
            summaryMessages.append("✅ Successfully imported \(result.importedCount) QSO(s)")
        }
        
        if result.duplicateCount > 0 {
            summaryMessages.append("⚠️ Found \(result.duplicateCount) duplicate QSO(s) - skipped")
        }
        
        if result.errorCount > 0 {
            summaryMessages.append("❌ \(result.errorCount) QSO(s) failed to import due to errors")
        }
        
        if result.warnings.count > 0 {
            summaryMessages.append("⚠️ \(result.warnings.count) warning(s) during import")
        }
        
        // Show detailed error information if there are errors
        if result.errorCount > 0 {
            let errorDetails = result.errors.prefix(5).map { "Line \($0.lineNumber): \($0.message)" }.joined(separator: "\n")
            let errorMessage = summaryMessages.joined(separator: "\n") + "\n\nFirst few errors:\n" + errorDetails
            showError(message: errorMessage)
        } else if result.warnings.count > 0 {
            // Show warnings if no errors but warnings exist
            let warningDetails = result.warnings.prefix(3).map { "Line \($0.lineNumber): \($0.message)" }.joined(separator: "\n")
            let warningMessage = summaryMessages.joined(separator: "\n") + "\n\nFirst few warnings:\n" + warningDetails
            showError(message: warningMessage)
        } else {
            // Success message
            let successMessage = summaryMessages.joined(separator: "\n")
            showError(message: successMessage)
        }
        
        loadQSOs()
    }
    
    func previewADIFImport(_ adifContent: String) -> ImportResult {
        // Use a temporary context for preview to avoid affecting the main data
        let tempContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        tempContext.parent = context
        
        let tempADIFService = ADIFService(context: tempContext)
        let result = tempADIFService.importFromADIF(adifContent)
        
        // Clean up temporary context
        tempContext.rollback()
        
        return result
    }
    
    // MARK: - Helper Methods
    private func saveContext() {
        do {
            try context.save()
        } catch {
            showError(message: "Failed to save: \(error.localizedDescription)")
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }

    // MARK: - Station defaults safeguard
    private func ensureDefaultStationExists() {
        let request: NSFetchRequest<StationProfile> = StationProfile.fetchRequest()
        request.fetchLimit = 1
        do {
            let count = try context.count(for: request)
            if count == 0 {
                let defaults: [(String, String, String, Double, Bool)] = [
                    ("Home", "20m", "SSB", 100.0, true),
                    ("Portable", "40m", "CW", 50.0, false),
                    ("Mobile", "2m", "FM", 25.0, false)
                ]
                for (name, band, mode, power, isDefault) in defaults {
                    let station = StationProfile(context: context)
                    station.id = UUID()
                    station.name = name
                    station.defaultBand = band
                    station.defaultMode = mode
                    station.defaultPowerW = power
                    station.isDefault = isDefault
                }
                try context.save()
            }
        } catch {
            // Non-fatal; do nothing
        }
    }
}

// MARK: - Supporting Types
struct QSOData {
    var datetime: Date?
    var callsign: String?
    var band: String?
    var mode: String?
    var frequencyMHz: Double?
    var rstSent: String?
    var rstReceived: String?
    var txPowerW: Double?
    var operatorCallsign: String?
    var grid: String?
    var dxcc: String?
    var qth: String?
    var rig: String?
    var antenna: String?
    var contestName: String?
    var serialSent: Int16?
    var serialReceived: Int16?
    var qsoDurationSec: Int32?
    var notes: String?
    var station: StationProfile?
}

enum DateRange: String, CaseIterable {
    case allTime = "All Time"
    case today = "Today"
    case yesterday = "Yesterday"
    case lastWeek = "Last Week"
    case lastMonth = "Last Month"
    case lastYear = "Last Year"
    
    func contains(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .allTime:
            return true
        case .today:
            return calendar.isDate(date, inSameDayAs: now)
        case .yesterday:
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
            return calendar.isDate(date, inSameDayAs: yesterday)
        case .lastWeek:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return date >= weekAgo
        case .lastMonth:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return date >= monthAgo
        case .lastYear:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return date >= yearAgo
        }
    }
}

enum QSLFilter: String, CaseIterable {
    case all = "All"
    case sent = "Sent"
    case received = "Received"
    case pending = "Pending"
}

struct QSOAnalytics {
    var totalQSOs = 0
    var qsosByBand: [String: Int] = [:]
    var qsosByMode: [String: Int] = [:]
    var qsosByDay: [Date: Int] = [:]
    var qslSentCount = 0
    var qslReceivedCount = 0
    var uniqueCallsigns = 0
    var dxccEntities = 0
}
