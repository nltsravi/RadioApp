//
//  BandModeCatalog.swift
//  RadioApp
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//

import Foundation

// MARK: - Band Catalog
struct BandCatalog {
    static let standardBands = [
        "160m": 1.8,
        "80m": 3.5,
        "40m": 7.0,
        "30m": 10.1,
        "20m": 14.0,
        "17m": 18.068,
        "15m": 21.0,
        "12m": 24.89,
        "10m": 28.0,
        "6m": 50.0,
        "2m": 144.0,
        "70cm": 432.0,
        "23cm": 1296.0,
        "13cm": 2304.0,
        "9cm": 3456.0,
        "6cm": 5760.0,
        "3cm": 10368.0
    ]
    
    static let bandNames = Array(standardBands.keys).sorted { band1, band2 in
        guard let freq1 = standardBands[band1], let freq2 = standardBands[band2] else {
            return band1 < band2
        }
        return freq1 < freq2
    }
    
    static func frequency(for band: String) -> Double? {
        return standardBands[band]
    }
    
    static func band(for frequency: Double) -> String? {
        return standardBands.first { abs($0.value - frequency) < 0.1 }?.key
    }
}

// MARK: - Mode Catalog
struct ModeCatalog {
    static let standardModes = [
        "SSB": "Single Side Band",
        "AM": "Amplitude Modulation",
        "FM": "Frequency Modulation",
        "CW": "Continuous Wave",
        "FT8": "FT8 Digital",
        "FT4": "FT4 Digital",
        "RTTY": "Radio Teletype",
        "PSK31": "PSK31 Digital",
        "SSTV": "Slow Scan TV",
        "JT65": "JT65 Digital",
        "JT9": "JT9 Digital",
        "WSPR": "Weak Signal Propagation Reporter",
        "FSK441": "FSK441 Digital",
        "Hellschreiber": "Hellschreiber",
        "Olivia": "Olivia Digital",
        "Contestia": "Contestia Digital",
        "MFSK16": "MFSK16 Digital",
        "DominoEX": "DominoEX Digital",
        "THOR": "THOR Digital",
        "MT63": "MT63 Digital",
        "PACTOR": "PACTOR Digital",
        "WINMOR": "WINMOR Digital",
        "VARA": "VARA Digital",
        "Packet": "Packet Radio",
        "APRS": "Automatic Packet Reporting System",
        "D-Star": "D-Star Digital Voice",
        "DMR": "Digital Mobile Radio",
        "P25": "Project 25",
        "Fusion": "Yaesu System Fusion",
        "DPMR": "Digital Private Mobile Radio",
        "NXDN": "NXDN Digital",
        "POCSAG": "POCSAG Paging",
        "ADS-B": "Automatic Dependent Surveillance-Broadcast",
        "AIS": "Automatic Identification System",
        "WEFAX": "Weather Facsimile",
        "NAVTEX": "Navigational Telex",
        "DSC": "Digital Selective Calling"
    ]
    
    static let modeNames = Array(standardModes.keys).sorted()
    
    static func description(for mode: String) -> String? {
        return standardModes[mode]
    }
    
    static let contestModes = ["SSB", "CW", "FT8", "FT4", "RTTY", "PSK31"]
    static let digitalModes = ["FT8", "FT4", "RTTY", "PSK31", "JT65", "JT9", "WSPR", "FSK441", "Olivia", "Contestia", "MFSK16", "DominoEX", "THOR", "MT63"]
    static let voiceModes = ["SSB", "AM", "FM", "D-Star", "DMR", "P25", "Fusion", "DPMR", "NXDN"]
}

// MARK: - RST Scale
struct RSTScale {
    static let readability = ["1", "2", "3", "4", "5"]
    static let strength = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    static let tone = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    static func isValidRST(_ rst: String) -> Bool {
        // Check if it's a valid RST report (e.g., "59", "599", "5999")
        let pattern = "^[1-5][1-9][1-9]?[1-9]?$"
        return rst.range(of: pattern, options: .regularExpression) != nil
    }
    
    static func formatRST(readability: String, strength: String, tone: String? = nil) -> String {
        if let tone = tone {
            return readability + strength + tone
        }
        return readability + strength
    }
}

// MARK: - QSL Methods
struct QSLMethods {
    static let methods = [
        "Paper": "Paper QSL Card",
        "LoTW": "Logbook of the World",
        "eQSL": "eQSL.cc",
        "Bureau": "QSL Bureau",
        "Direct": "Direct Mail",
        "Manager": "QSL Manager"
    ]
    
    static let methodNames = Array(methods.keys).sorted()
    
    static func description(for method: String) -> String? {
        return methods[method]
    }
}
