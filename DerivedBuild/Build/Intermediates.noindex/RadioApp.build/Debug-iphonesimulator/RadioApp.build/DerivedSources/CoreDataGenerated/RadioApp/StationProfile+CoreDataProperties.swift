//
//  StationProfile+CoreDataProperties.swift
//  
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension StationProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StationProfile> {
        return NSFetchRequest<StationProfile>(entityName: "StationProfile")
    }

    @NSManaged public var defaultBand: String?
    @NSManaged public var defaultMode: String?
    @NSManaged public var defaultPowerW: Double
    @NSManaged public var id: UUID?
    @NSManaged public var isDefault: Bool
    @NSManaged public var name: String?
    @NSManaged public var operatorCallsign: String?
    @NSManaged public var rig: String?
    @NSManaged public var antenna: String?
    @NSManaged public var qsos: NSSet?

}

// MARK: Generated accessors for qsos
extension StationProfile {

    @objc(addQsosObject:)
    @NSManaged public func addToQsos(_ value: QSO)

    @objc(removeQsosObject:)
    @NSManaged public func removeFromQsos(_ value: QSO)

    @objc(addQsos:)
    @NSManaged public func addToQsos(_ values: NSSet)

    @objc(removeQsos:)
    @NSManaged public func removeFromQsos(_ values: NSSet)

}

extension StationProfile : Identifiable {

}
