//
//  ListViewController.swift
//  Handshake
//
//  Created by Hanna Koh on 4/29/15.
//  Copyright (c) 2015 Hanna Koh. All rights reserved.
//

import Foundation
import UIKit
import AddressBookUI
import AddressBook

class ListViewController: UITableViewController, UINavigationControllerDelegate, ABNewPersonViewControllerDelegate, PebbleHelperDelegate {
    let itemsManager: ItemsManager
    let keyData = 5
    let pebbleHelper: PebbleHelper
    var selectedRow:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)

    required init(coder aDecoder: NSCoder)
    {
        itemsManager = ItemsManager()
        println(itemsManager.items.count)
        pebbleHelper = PebbleHelper.instance
        super.init(coder: aDecoder)
        if itemsManager.items.count == 0 {
            itemsManager.items.append(Contact(aName: "", aPhone: "", aEmail: ""))
            itemsManager.save()
        }
        pebbleHelper.delegate = self
        pebbleHelper.UUID = "477f4e78-fc52-4815-9963-c67dd72b18ca"

    }
    
    func pebbleHelper(pebbleHelper: PebbleHelper, receivedMessage: Dictionary<NSObject, AnyObject>) -> Void {
        println("Received Message")
        var str = ""
        for (key, value) in receivedMessage {
            str += (value as String)
        }
        var contact = parseString(str)
        itemsManager.items.append(contact)
        itemsManager.save()
        let insertionRow = itemsManager.items.count-2
        let indexPath = NSIndexPath(forRow:insertionRow , inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation:.Automatic)
    }
    
    func parseString(str: String) -> Contact {
        var strArr = str.componentsSeparatedByString(",")
        return Contact(aName: strArr[0], aPhone: strArr[1], aEmail: strArr[2])
    }


    // MARK: UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsManager.items.count-1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ListViewCell", forIndexPath: indexPath) as UITableViewCell
        
        let item = itemsManager.items[indexPath.row+1]
        cell.textLabel?.text = item.name + ", " + item.phone + ", " + item.email
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath
        let item = itemsManager.items[indexPath.row+1]
        var strArr = item.name.componentsSeparatedByString(" ")
        var person:ABRecord! = ABPersonCreate().takeRetainedValue() as ABRecordRef
        ABRecordSetValue(person, kABPersonFirstNameProperty, strArr[0], nil)
        ABRecordSetValue(person, kABPersonLastNameProperty, strArr[1], nil)
        var phoneNumber:ABRecordRef = ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue() as ABRecordRef
        ABMultiValueAddValueAndLabel(phoneNumber, item.phone, kABPersonPhoneMobileLabel, nil);
        var emailAddress:ABRecordRef = ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue() as ABRecordRef
        ABMultiValueAddValueAndLabel(phoneNumber, item.email, kABWorkLabel, nil);

        ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumber, nil)
        ABRecordSetValue(person, kABPersonEmailProperty, emailAddress, nil)
        let controller = ABNewPersonViewController()
        controller.newPersonViewDelegate = self
        controller.displayedPerson = person;
        let navigationController = UINavigationController(rootViewController: controller)
        self.presentViewController(navigationController, animated: true, completion: nil)
        return
    }
    
    func newPersonViewController(newPersonView: ABNewPersonViewController!, didCompleteWithNewPerson person: ABRecord!) {
        newPersonView.navigationController?.dismissViewControllerAnimated(true, completion: nil);
        if person != nil {
            tableView.beginUpdates()
            itemsManager.items.removeAtIndex(selectedRow.row+1)
            itemsManager.save()
            tableView.deleteRowsAtIndexPaths([selectedRow], withRowAnimation: UITableViewRowAnimation.Automatic)
            tableView.endUpdates()
        }
    }
    // MARK: Segues
    
    @IBAction func unwindToList(segue: UIStoryboardSegue) {
        if segue.identifier == "DoneItem" {
            println("Reached")
            let settingsItemController = segue.sourceViewController as SettingsViewController
            if let newItem = settingsItemController.newItem {
                itemsManager.items[0] = newItem
                itemsManager.save()
            }
        }

    }
}


