//
//  SettingsViewController.swift
//  Handshake
//
//  Created by Hanna Koh on 4/30/15.
//  Copyright (c) 2015 Hanna Koh. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var email: UITextField!
    
    var newItem: Contact?
    
    let itemsManager: ItemsManager
    
    required init?(coder aDecoder: NSCoder) {
        self.itemsManager = ItemsManager()
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = itemsManager.items[0].name
        phone.text = itemsManager.items[0].phone
        email.text = itemsManager.items[0].email
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "DoneItem" {
            if let name1 = name.text {
                if let phone1 = phone.text {
                    if let email1 = email.text {
                        if !name1.isEmpty && !phone1.isEmpty && !email1.isEmpty {
                            newItem = Contact(aName: name1, aPhone: phone1, aEmail: email1)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

