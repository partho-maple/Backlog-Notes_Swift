import Foundation
import UIKit
import Swift


class ChecklistItem: NSObject, NSCoding {
    ///declare propertis of the items we want to store
    var notes: String = ""
    var dueDate: NSDate
    var shouldRemind: Bool
    var itemId: Int = 0
    ///declare method to schedule local notification
    
    required init?(coder aDecoder: NSCoder) {
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if (self.init()) {
            self.notes = aDecoder.decodeObjectForKey("Notes")
            self.dueDate = aDecoder.decodeObjectForKey("DueDate")
            self.shouldRemind = aDecoder.decodeBoolForKey("ShouldRemind")
            self.itemId = aDecoder.decodeIntForKey("ItemID")
        }
    }

    func scheduleNotification() {
        var existingNotification: UILocalNotification = self.notificationForThisItem()
        if existingNotification != nil {
            UIApplication.sharedApplication().cancelLocalNotification(self.notificationForThisItem())
        }
        if self.shouldRemind && self.dueDate.compare(NSDate()) != NSOrderedAscending {
            var localNotification: UILocalNotification = UILocalNotification()
            localNotification.fireDate = self.dueDate
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.alertBody = self.notes
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.userInfo = [
                "ItemID" : Int(self.itemId)
            ]

            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            NSLog("Scheduled notification %@ for itemId %d", localNotification, self.itemId)
        }
    }

    ///synthesize the declared properties
    ///method to decode

    
    ///method to encode

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.notes, forKey: "Notes")
        aCoder.encodeObject(self.dueDate, forKey: "DueDate")
        aCoder.encodeBool(self.shouldRemind, forKey: "ShouldRemind")
        aCoder.encodeInt(self.itemId, forKey: "ItemID")
    }
    ///We need to assign an id for each item.

    convenience override init() {
        if self.dynamicType.init() {
            self.itemId = DataModel.nextChecklistItemId()
        }
    }
    ///We need to assign an id for each item so that we can easily identify.

    func notificationForThisItem() -> UILocalNotification {
        var allNotifications: [AnyObject] = UIApplication.sharedApplication().scheduledLocalNotifications!()
        for notification: UILocalNotification in allNotifications {
            var number: Int = (notification.userInfo!["ItemID"] as! Int)
            if number != nil && CInt(number)! == self.itemId {
                return notification
            }
        }
        return nil
    }
    ///We schedule notification here for the selected item. If there is any existing notification for this item, we remove them so that only latest alarm time will be fired.

    func dealloc() {
        var existingNotification: UILocalNotification = self.notificationForThisItem()
        if existingNotification != nil {
            //   NSLog(@"Removing existing notification %@", existingNotification);
            UIApplication.sharedApplication().cancelLocalNotification(existingNotification)
        }
    }
}