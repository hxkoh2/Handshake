//
//  Contacts.swift
//  Handshake
//
//  Created by Hanna Koh on 4/29/15.
//  Copyright (c) 2015 Hanna Koh. All rights reserved.
//

import Foundation
import UIKit

let NameKey = "nameKey"
let PhotoKey = "photoKey"


class ScavengerHuntItem: NSObject, NSCoding {
    // MARK: Properties
    
    let name: String
    var photo: UIImage?
    
    var isComplete: Bool {
        get {
            return photo != nil
        }
    }
    
    // MARK: Initializers
    
    init(name aName: String) {
        name = aName
    }
    
    // MARK: NSCoding
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey(NameKey) as String
        photo = aDecoder.decodeObjectForKey(PhotoKey) as? UIImage
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(name, forKey: NameKey)
        if let thePhoto = photo {
            coder.encodeObject(thePhoto, forKey: PhotoKey)
        }
    }
}