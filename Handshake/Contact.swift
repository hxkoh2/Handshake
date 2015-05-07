//
//  Contact.swift
//  Handshake
//
//  Created by Hanna Koh on 4/29/15.
//  Copyright (c) 2015 Hanna Koh. All rights reserved.
//

import UIKit

let NameKey = "nameKey"
let PhoneKey = "phoneKey"
let EmailKey = "emailKey"


class Contact: NSObject, NSCoding {
    // MARK: Properties
    
    let name: String
    let phone: String
    let email: String
    
    init(aName: String, aPhone: String, aEmail: String) {
        self.name = aName
        self.phone = aPhone
        self.email = aEmail
    }
    
    // MARK: NSCoding
    
    required init(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey(NameKey) as String
        self.phone = aDecoder.decodeObjectForKey(PhoneKey) as String
        self.email = aDecoder.decodeObjectForKey(EmailKey) as String
        //super.init()
    }
    
    func encodeWithCoder(_aCoder: NSCoder) {
        _aCoder.encodeObject(self.name, forKey: NameKey)
        _aCoder.encodeObject(self.phone, forKey: PhoneKey)
        _aCoder.encodeObject(self.email, forKey: EmailKey)
    }
}