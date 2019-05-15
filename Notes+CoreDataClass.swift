//
//  Notes+CoreDataClass.swift
//  Notes
//
//  Created by fo_0x on 12.05.2019.
//  Copyright © 2019 fo_0x. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Notes)
public class Notes: NSManagedObject {
    @NSManaged public var notes: String
    @NSManaged public var timeAndDate: String
}
