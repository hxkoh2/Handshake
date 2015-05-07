//
//  ItemsManager.swift
//  Handshake
//
//  Created by Hanna Koh on 4/29/15.
//  Copyright (c) 2015 Hanna Koh. All rights reserved.
//

import Foundation

class ItemsManager {
    // MARK: Properties
    
    //First contact is always your own
    var items = [Contact]()
    
    // MARK: Initializers
    
    init() {
        unarchiveSavedItems()
    }
    
    // MARK: Saving
    func save() {
        NSKeyedArchiver.archiveRootObject(items, toFile: archivePath)
    }
    
    // MARK: Private Convenience
    
    private func unarchiveSavedItems() {
        if NSFileManager.defaultManager().fileExistsAtPath(archivePath) {
            if let savedItems = NSKeyedUnarchiver.unarchiveObjectWithFile(archivePath) as? [Contact] {
                items += savedItems
            }
            
        }
    }
    
    lazy private var archivePath: String = {
        let fileManager = NSFileManager.defaultManager()
        
        let documentsDirectoryURLs = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) as [NSURL]
        
        let archiveURL = documentsDirectoryURLs.first!.URLByAppendingPathComponent("Contacts", isDirectory: false)
        
        return archiveURL.path!
        }()
}
