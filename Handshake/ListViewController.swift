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
import CoreLocation

class ListViewController: UITableViewController, UINavigationControllerDelegate, ABNewPersonViewControllerDelegate, CLLocationManagerDelegate, PebbleHelperDelegate {
    let itemsManager: ItemsManager
    let keyData = 5
    let pebbleHelper: PebbleHelper
    let connectionManager: ConnectionManager
    var selectedRow: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    //var locationManager: CLLocationManager!
    
    required init?(coder aDecoder: NSCoder)
    {
        itemsManager = ItemsManager()
        connectionManager = ConnectionManager()
        //locationManager = CLLocationManager()
        print(itemsManager.items.count)
        pebbleHelper = PebbleHelper.instance
        super.init(coder: aDecoder)!
        if itemsManager.items.count == 0 {
            itemsManager.items.append(Contact(aName: "", aPhone: "", aEmail: ""))
            itemsManager.save()
        }
        pebbleHelper.delegate = self
        pebbleHelper.UUID = "477f4e78-fc52-4815-9963-c67dd72b18ca"
        connectionManager.delegate = self
        /*// Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }*/
    }
    
    
    /*func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //let locValue:CLLocation = manager.location!
        //connectionManager.serviceAdvertiser.discoveryInfo = ["longitude": String(locValue.longitude)]
        locationManager.stopUpdatingLocation()
        print("Current location: longitude \(locations[locations.count - 1].coordinate.longitude) latitude \(locations[locations.count - 1].coordinate.latitude)")
        print("Distance from couch in meters: \(couch.distanceFromLocation(locations[locations.count - 1]))")
    }*/
    
    func pebbleHelper(pebbleHelper: PebbleHelper, receivedMessage: Dictionary<NSObject, AnyObject>) -> Void {
        print("Received Message")
        connectionManager.serviceAdvertiser.startAdvertisingPeer()
        connectionManager.serviceBrowser.startBrowsingForPeers()
        print("Started advertising and browsing myself")
        
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
        cell.textLabel?.text = item.name + "\n " + item.phone + "\n " + item.email
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath
        let item = itemsManager.items[indexPath.row+1]
        var strArr = item.name.componentsSeparatedByString(" ")
        let person:ABRecord! = ABPersonCreate().takeRetainedValue() as ABRecordRef
        ABRecordSetValue(person, kABPersonFirstNameProperty, strArr[0], nil)
        if (strArr.count > 1) {
            ABRecordSetValue(person, kABPersonLastNameProperty, strArr[1], nil)
        }
        let phoneNumber:ABRecordRef = ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue() as ABRecordRef
        ABMultiValueAddValueAndLabel(phoneNumber, item.phone, kABPersonPhoneMobileLabel, nil);
        let emailAddress:ABRecordRef = ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue() as ABRecordRef
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
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            tableView.beginUpdates()
            itemsManager.items.removeAtIndex(indexPath.row+1)
            itemsManager.save()
            tableView.deleteRowsAtIndexPaths([indexPath],  withRowAnimation: UITableViewRowAnimation.Automatic)
            tableView.endUpdates()
        }
    }
    
    func newPersonViewController(newPersonView: ABNewPersonViewController, didCompleteWithNewPerson person: ABRecord?) {
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
            let settingsItemController = segue.sourceViewController as! SettingsViewController
            if let newItem = settingsItemController.newItem {
                itemsManager.items[0] = newItem
                itemsManager.save()
            }
        }

    }
}

extension ListViewController : ConnectionManagerDelegate {
    func connectedDevicesChanged(manager : ConnectionManager, connectedDevices: [String]) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            NSLog("%@", "Connections: \(connectedDevices)")
        }
        let myContact = itemsManager.items[0]
        connectionManager.sendContacts(myContact)
    }
    
    func receivedData(manager : ConnectionManager, contact : Contact) {
        itemsManager.items.append(contact)
        itemsManager.save()
        let insertionRow = itemsManager.items.count-2
        let indexPath = NSIndexPath(forRow:insertionRow , inSection: 0)
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation:.Automatic)
        tableView.endUpdates()
        
        connectionManager.serviceAdvertiser.stopAdvertisingPeer()
        connectionManager.serviceBrowser.stopBrowsingForPeers()
        print("Stopped advertising and browsing myself")
        
        /*let alertController = UIAlertController(title: "Handshake", message: "Received new contact: \(contact.name)", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true) { }*/
        

        var notification = UILocalNotification()
        notification.alertAction = "open"
        //notification.alertTitle = "Handshake received a contact"
        notification.alertBody = "Hanshake received a contact: \(contact.name)"
        notification.soundName = UILocalNotificationDefaultSoundName
        
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound, categories: nil))
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil))
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Badge, categories: nil))
        }
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
}



