
import Foundation


class DataModel: NSObject {

    class func nextChecklistItemId() -> Int {
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let itemId: Int = userDefaults.integerForKey("ChecklistItemId")
        userDefaults.setInteger(itemId + 1, forKey: "ChecklistItemId")
        userDefaults.synchronize()
        return itemId
    }


    func registerDefaults() {
        let dictionary: [NSObject : AnyObject] = [
                "FirstTime" : Int(true),
                "ChecklistItemId" : Int(0)
            ]

        NSUserDefaults.standardUserDefaults().registerDefaults(dictionary)
    }

    
    func handleFirstTime() {
        let firstTime: Bool = NSUserDefaults.standardUserDefaults().boolForKey("FirstTime")
        if firstTime {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "FirstTime")
        }
    }

    
    convenience override init() {
        if (self.init()) {
            self.registerDefaults()
            self.handleFirstTime()
        }
    }

}