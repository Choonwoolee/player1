//
//  Audio.swift
//  player1
//
//  Created by choonlog on 2014. 12. 4..
//  Copyright (c) 2014년 choonlog. All rights reserved.
//

import Foundation
import CoreData

class Audio: NSManagedObject {

    @NSManaged var audioId: NSNumber
    @NSManaged var playCount: NSNumber
    @NSManaged var title: String
    @NSManaged var bookmarks: NSSet

}
