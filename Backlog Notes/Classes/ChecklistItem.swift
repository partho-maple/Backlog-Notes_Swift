import Foundation
import UIKit
import Swift


class ChecklistItem: NSObject, NSCoding {

    var notes: String = ""
    var dueDate: NSDate = NSDate()
    var shouldRemind: Bool = false
    var itemId: Int = 0
    
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

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.notes, forKey: "Notes")
        aCoder.encodeObject(self.dueDate, forKey: "DueDate")
        aCoder.encodeBool(self.shouldRemind, forKey: "ShouldRemind")
        aCoder.encodeInt(self.itemId, forKey: "ItemID")
    }

    convenience override init() {
        if self.dynamicType.init() {
            self.itemId = DataModel.nextChecklistItemId()
        }
    }

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

    func dealloc() {
        var existingNotification: UILocalNotification = self.notificationForThisItem()
        if existingNotification != nil {
            UIApplication.sharedApplication().cancelLocalNotification(existingNotification)
        }
    }
}





