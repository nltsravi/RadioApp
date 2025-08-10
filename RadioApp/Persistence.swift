//
//  Persistence.swift
//  RadioApp
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//

import CoreData
import CloudKit

struct PersistenceController {
    static let shared = PersistenceController()
    
    // MARK: - CloudKit Configuration
    private static let cloudKitContainerIdentifier = "iCloud.com.yourcompany.qsolog"
    
    // MARK: - Preview
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for preview
        createSampleData(in: viewContext)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Preview data creation failed: \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer
    
    // MARK: - Initialization
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "RadioApp")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Configure CloudKit
        configureCloudKit()
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Core Data store failed to load: \(error), \(error.userInfo)")
                
                // Handle migration errors
                if error.code == NSPersistentStoreIncompatibleVersionHashError {
                    print("Data model version mismatch. Consider migration.")
                }
                
                // Handle CloudKit-specific errors
                if error.domain == "CKErrorDomain" {
                    print("CloudKit error: \(error.localizedDescription)")
                    // You might want to fall back to local-only mode here
                }
            } else {
                print("Core Data store loaded successfully")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - CloudKit Configuration
    private func configureCloudKit() {
        guard let storeDescription = container.persistentStoreDescriptions.first else { return }
        
        // Enable CloudKit sync
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // Check if CloudKit is available and user hasn't disabled it
        // For now, we'll always enable CloudKit, but this can be made conditional
        // based on user settings or iCloud availability
        let cloudKitOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: Self.cloudKitContainerIdentifier
        )
        storeDescription.cloudKitContainerOptions = cloudKitOptions
    }
    
    // MARK: - Local Only Mode
    func setLocalOnly(_ localOnly: Bool) {
        guard let storeDescription = container.persistentStoreDescriptions.first else { return }
        
        if localOnly {
            storeDescription.cloudKitContainerOptions = nil
        } else {
            let cloudKitOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: Self.cloudKitContainerIdentifier
            )
            storeDescription.cloudKitContainerOptions = cloudKitOptions
        }
    }
    
    // MARK: - Sample Data Creation
    @MainActor
    private static func createSampleData(in context: NSManagedObjectContext) {
        // Create default station profile
        let homeStation = StationProfile(context: context)
        homeStation.id = UUID()
        homeStation.name = "Home"
        homeStation.operatorCallsign = "W1AW"
        homeStation.rig = "IC-7300"
        homeStation.antenna = "Dipole"
        homeStation.defaultBand = "20m"
        homeStation.defaultMode = "SSB"
        homeStation.defaultPowerW = 100.0
        homeStation.isDefault = true
        
        // Create sample QSOs
        let sampleQSOs = [
            ("K1ABC", "20m", "SSB", "59", "59", 100.0, "FN31", "USA", "Boston, MA"),
            ("G4XYZ", "40m", "CW", "599", "599", 50.0, "IO91", "England", "London"),
            ("JA1DEF", "15m", "FT8", "599", "599", 100.0, "PM95", "Japan", "Tokyo")
        ]
        
        for (callsign, band, mode, rstSent, rstReceived, power, grid, dxcc, qth) in sampleQSOs {
            let qso = QSO(context: context)
            qso.id = UUID()
            qso.datetime = Date().addingTimeInterval(-Double.random(in: 0...86400*30)) // Random time in last 30 days
            qso.callsign = callsign
            qso.band = band
            qso.mode = mode
            qso.rstSent = rstSent
            qso.rstReceived = rstReceived
            qso.txPowerW = power
            qso.operatorCallsign = "W1AW"
            qso.grid = grid
            qso.dxcc = dxcc
            qso.qth = qth
            qso.station = homeStation
        }
        
        // Create app settings
        let settings = AppSettings(context: context)
        settings.id = UUID()
        settings.localOnly = false
        settings.defaultSort = "DateDesc"
        settings.enabledBands = ["160m", "80m", "40m", "20m", "17m", "15m", "12m", "10m", "6m", "2m", "70cm"]
        settings.enabledModes = ["SSB", "CW", "FT8", "FT4", "RTTY", "PSK31"]
        settings.enableHaptic = true
        settings.enableSounds = true
    }
    
    // MARK: - Save Context
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Failed to save context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
