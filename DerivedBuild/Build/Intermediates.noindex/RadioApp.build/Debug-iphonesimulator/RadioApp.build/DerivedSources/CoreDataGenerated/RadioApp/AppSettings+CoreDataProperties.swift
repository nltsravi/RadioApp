//
//  AppSettings+CoreDataProperties.swift
//  
//
//  Created by Ravishankar Jayaraman on 10/08/25.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension AppSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppSettings> {
        return NSFetchRequest<AppSettings>(entityName: "AppSettings")
    }

    @NSManaged public var enabledBands: [String]?
    @NSManaged public var enabledModes: [String]?
    @NSManaged public var enableHaptic: Bool
    @NSManaged public var enableSounds: Bool
    @NSManaged public var id: UUID?
    @NSManaged public var localOnly: Bool
    @NSManaged public var defaultSort: String?

}

extension AppSettings : Identifiable {

}
