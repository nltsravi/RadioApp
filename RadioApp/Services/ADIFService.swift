//
//  ADIFService.swift
//  RadioApp
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//

import Foundation
import CoreData

// MARK: - ADIF Field Definitions
struct ADIFField {
    static let call = "CALL"
    static let qsoDate = "QSO_DATE"
    static let timeOn = "TIME_ON"
    static let band = "BAND"
    static let freq = "FREQ"
    static let mode = "MODE"
    static let rstSent = "RST_SENT"
    static let rstRcvd = "RST_RCVD"
    static let txPwr = "TX_PWR"
    static let gridSquare = "GRIDSQUARE"
    static let qth = "QTH"
    static let country = "COUNTRY"
    static let operatorField = "OPERATOR"
    static let notes = "NOTES"
    static let qslSent = "QSL_SENT"
    static let qslRcvd = "QSL_RCVD"
    static let qslSentDate = "QSL_SENT_DATE"
    static let qslRcvdDate = "QSL_RCVD_DATE"
    static let qslMethod = "QSL_METHOD"
    static let rig = "RIG"
    static let antenna = "ANTENNA"
    static let contestName = "CONTEST_ID"
    static let serialSent = "STX"
    static let serialRcvd = "SRX"
    static let qsoDuration = "QSO_DURATION"
    static let dxcc = "DXCC"
}

// MARK: - ADIF Service
class ADIFService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Export to ADIF
    func exportToADIF(qsos: [QSO]) -> String {
        var adifContent = "Generated-By: QSO Log\r\n"
        adifContent += "ADIF_VER: 3.1.4\r\n"
        adifContent += "PROGRAMID: QSO Log\r\n"
        adifContent += "PROGRAMVERSION: 1.0\r\n"
        adifContent += "<EOH>\r\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HHmm"
        
        for qso in qsos {
            var qsoLine = ""
            
            // Required fields
            if let callsign = qso.callsign {
                qsoLine += "<\(ADIFField.call):\(callsign.count)>\(callsign)"
            }
            
            if let datetime = qso.datetime {
                qsoLine += "<\(ADIFField.qsoDate):8>\(dateFormatter.string(from: datetime))"
                qsoLine += "<\(ADIFField.timeOn):4>\(timeFormatter.string(from: datetime))"
            }
            
            if let band = qso.band {
                qsoLine += "<\(ADIFField.band):\(band.count)>\(band)"
            }
            
            if let mode = qso.mode {
                qsoLine += "<\(ADIFField.mode):\(mode.count)>\(mode)"
            }
            
            // Optional fields
            let freq = qso.frequencyMHz
            if freq > 0 {
                qsoLine += "<\(ADIFField.freq):\(String(format: "%.6f", freq).count)>\(String(format: "%.6f", freq))"
            }
            
            if let rstSent = qso.rstSent {
                qsoLine += "<\(ADIFField.rstSent):\(rstSent.count)>\(rstSent)"
            }
            
            if let rstReceived = qso.rstReceived {
                qsoLine += "<\(ADIFField.rstRcvd):\(rstReceived.count)>\(rstReceived)"
            }
            
            let txPower = qso.txPowerW
            if txPower > 0 {
                qsoLine += "<\(ADIFField.txPwr):\(String(format: "%.1f", txPower).count)>\(String(format: "%.1f", txPower))"
            }
            
            if let grid = qso.grid {
                qsoLine += "<\(ADIFField.gridSquare):\(grid.count)>\(grid)"
            }
            
            if let qth = qso.qth {
                qsoLine += "<\(ADIFField.qth):\(qth.count)>\(qth)"
            }
            
            if let dxcc = qso.dxcc {
                qsoLine += "<\(ADIFField.dxcc):\(dxcc.count)>\(dxcc)"
            }
            
            if let operatorCallsign = qso.operatorCallsign {
                qsoLine += "<\(ADIFField.operatorField):\(operatorCallsign.count)>\(operatorCallsign)"
            }
            
            if let notes = qso.notes {
                qsoLine += "<\(ADIFField.notes):\(notes.count)>\(notes)"
            }
            
            if let rig = qso.rig {
                qsoLine += "<\(ADIFField.rig):\(rig.count)>\(rig)"
            }
            
            if let antenna = qso.antenna {
                qsoLine += "<\(ADIFField.antenna):\(antenna.count)>\(antenna)"
            }
            
            if let contestName = qso.contestName {
                qsoLine += "<\(ADIFField.contestName):\(contestName.count)>\(contestName)"
            }
            
            let serialSent = qso.serialSent
            if serialSent > 0 {
                qsoLine += "<\(ADIFField.serialSent):\(String(serialSent).count)>\(serialSent)"
            }
            
            let serialReceived = qso.serialReceived
            if serialReceived > 0 {
                qsoLine += "<\(ADIFField.serialRcvd):\(String(serialReceived).count)>\(serialReceived)"
            }
            
            let duration = qso.qsoDurationSec
            if duration > 0 {
                qsoLine += "<\(ADIFField.qsoDuration):\(String(duration).count)>\(duration)"
            }
            
            // QSL fields
            if qso.qslSent {
                qsoLine += "<\(ADIFField.qslSent):1>Y"
                if let qslSentDate = qso.qslSentDate {
                    qsoLine += "<\(ADIFField.qslSentDate):8>\(dateFormatter.string(from: qslSentDate))"
                }
            }
            
            if qso.qslReceived {
                qsoLine += "<\(ADIFField.qslRcvd):1>Y"
                if let qslReceivedDate = qso.qslReceivedDate {
                    qsoLine += "<\(ADIFField.qslRcvdDate):8>\(dateFormatter.string(from: qslReceivedDate))"
                }
            }
            
            if let qslMethod = qso.qslMethod {
                qsoLine += "<\(ADIFField.qslMethod):\(qslMethod.count)>\(qslMethod)"
            }
            
            qsoLine += "<eor>\r\n"
            adifContent += qsoLine
        }
        
        return adifContent
    }
    
    // MARK: - Import from ADIF
    func importFromADIF(_ adifContent: String) -> ImportResult {
        var importedCount = 0
        var errors: [ImportError] = []
        var duplicates: [QSO] = []
        
        let lines = adifContent.components(separatedBy: .newlines)
        var currentQSO: [String: String] = [:]
        
        for (lineNumber, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("Generated-By:") || 
               trimmedLine.hasPrefix("ADIF_VER:") || trimmedLine.hasPrefix("PROGRAMID:") ||
               trimmedLine.hasPrefix("PROGRAMVERSION:") || trimmedLine == "<EOH>" {
                continue
            }
            
            if trimmedLine == "<eor>" {
                // Process the current QSO
                if let qso = createQSOFromADIF(currentQSO) {
                    // Check for duplicates
                    if let existingQSO = findDuplicateQSO(qso) {
                        duplicates.append(existingQSO)
                    } else {
                        do {
                            try context.save()
                            importedCount += 1
                        } catch {
                            errors.append(ImportError(lineNumber: lineNumber, message: "Failed to save QSO: \(error.localizedDescription)"))
                        }
                    }
                }
                currentQSO.removeAll()
                continue
            }
            
            // Parse ADIF field
            if let field = parseADIFField(trimmedLine) {
                currentQSO[field.key] = field.value
            }
        }
        
        return ImportResult(
            importedCount: importedCount,
            errorCount: errors.count,
            duplicateCount: duplicates.count,
            errors: errors,
            duplicates: duplicates
        )
    }
    
    // MARK: - Helper Methods
    private func parseADIFField(_ line: String) -> (key: String, value: String)? {
        let pattern = "<([^:>]+):(\\d+)>"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) else {
            return nil
        }
        
        let fieldNameRange = Range(match.range(at: 1), in: line)!
        let lengthRange = Range(match.range(at: 2), in: line)!
        
        let fieldName = String(line[fieldNameRange])
        let length = Int(line[lengthRange]) ?? 0
        
        let valueStartIndex = line.index(line.startIndex, offsetBy: match.range.length)
        let valueEndIndex = line.index(valueStartIndex, offsetBy: length)
        
        guard valueEndIndex <= line.endIndex else { return nil }
        
        let value = String(line[valueStartIndex..<valueEndIndex])
        return (fieldName, value)
    }
    
    private func createQSOFromADIF(_ fields: [String: String]) -> QSO? {
        let qso = QSO(context: context)
        qso.id = UUID()
        
        // Parse date and time
        if let dateStr = fields[ADIFField.qsoDate], let timeStr = fields[ADIFField.timeOn] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmm"
            if let datetime = dateFormatter.date(from: dateStr + timeStr) {
                qso.datetime = datetime
            }
        }
        
        // Basic fields
        qso.callsign = fields[ADIFField.call]?.uppercased()
        qso.band = fields[ADIFField.band]
        qso.mode = fields[ADIFField.mode]
        qso.rstSent = fields[ADIFField.rstSent]
        qso.rstReceived = fields[ADIFField.rstRcvd]
        qso.operatorCallsign = fields[ADIFField.operatorField]
        qso.grid = fields[ADIFField.gridSquare]
        qso.qth = fields[ADIFField.qth]
        qso.dxcc = fields[ADIFField.country] ?? fields[ADIFField.dxcc]
        qso.notes = fields[ADIFField.notes]
        qso.rig = fields[ADIFField.rig]
        qso.antenna = fields[ADIFField.antenna]
        qso.contestName = fields[ADIFField.contestName]
        qso.qslMethod = fields[ADIFField.qslMethod]
        
        // Numeric fields
        if let freqStr = fields[ADIFField.freq], let freq = Double(freqStr) {
            qso.frequencyMHz = freq
        }
        
        if let powerStr = fields[ADIFField.txPwr], let power = Double(powerStr) {
            qso.txPowerW = power
        }
        
        if let serialSentStr = fields[ADIFField.serialSent], let serialSent = Int16(serialSentStr) {
            qso.serialSent = serialSent
        }
        
        if let serialRcvdStr = fields[ADIFField.serialRcvd], let serialRcvd = Int16(serialRcvdStr) {
            qso.serialReceived = serialRcvd
        }
        
        if let durationStr = fields[ADIFField.qsoDuration], let duration = Int32(durationStr) {
            qso.qsoDurationSec = duration
        }
        
        // QSL fields
        qso.qslSent = fields[ADIFField.qslSent] == "Y"
        qso.qslReceived = fields[ADIFField.qslRcvd] == "Y"
        
        if let qslSentDateStr = fields[ADIFField.qslSentDate] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            qso.qslSentDate = dateFormatter.date(from: qslSentDateStr)
        }
        
        if let qslRcvdDateStr = fields[ADIFField.qslRcvdDate] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            qso.qslReceivedDate = dateFormatter.date(from: qslRcvdDateStr)
        }
        
        return qso
    }
    
    private func findDuplicateQSO(_ newQSO: QSO) -> QSO? {
        guard let callsign = newQSO.callsign,
              let datetime = newQSO.datetime,
              let band = newQSO.band,
              let mode = newQSO.mode else {
            return nil
        }
        
        let request: NSFetchRequest<QSO> = QSO.fetchRequest()
        let twoMinutesBefore = datetime.addingTimeInterval(-120)
        let twoMinutesAfter = datetime.addingTimeInterval(120)
        request.predicate = NSPredicate(format: "callsign == %@ AND band == %@ AND mode == %@ AND datetime BETWEEN %@ AND %@",
                                       callsign, band, mode,
                                       twoMinutesBefore as NSDate, // 2 minutes before
                                       twoMinutesAfter as NSDate)  // 2 minutes after
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            return nil
        }
    }
}

// MARK: - Import Result
struct ImportResult {
    let importedCount: Int
    let errorCount: Int
    let duplicateCount: Int
    let errors: [ImportError]
    let duplicates: [QSO]
}

// MARK: - Import Error
struct ImportError {
    let lineNumber: Int
    let message: String
}
