//
//  QSO+CoreDataProperties.swift
//  
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension QSO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QSO> {
        return NSFetchRequest<QSO>(entityName: "QSO")
    }

    @NSManaged public var antenna: String?
    @NSManaged public var band: String?
    @NSManaged public var callsign: String?
    @NSManaged public var contestName: String?
    @NSManaged public var datetime: Date?
    @NSManaged public var dxcc: String?
    @NSManaged public var frequencyMHz: Double
    @NSManaged public var grid: String?
    @NSManaged public var id: UUID?
    @NSManaged public var mode: String?
    @NSManaged public var notes: String?
    @NSManaged public var operatorCallsign: String?
    @NSManaged public var qslMethod: String?
    @NSManaged public var qslReceived: Bool
    @NSManaged public var qslReceivedDate: Date?
    @NSManaged public var qslSent: Bool
    @NSManaged public var qslSentDate: Date?
    @NSManaged public var qsoDurationSec: Int32
    @NSManaged public var qth: String?
    @NSManaged public var rig: String?
    @NSManaged public var rstReceived: String?
    @NSManaged public var rstSent: String?
    @NSManaged public var serialReceived: Int16
    @NSManaged public var serialSent: Int16
    @NSManaged public var txPowerW: Double
    @NSManaged public var station: StationProfile?

}

extension QSO : Identifiable {

}
