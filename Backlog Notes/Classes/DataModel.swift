import Foundation
class DataModel: NSObject {
    /// We declare nextChecklistItemId method to assign an ID for each notification scheduled.
    class func nextChecklistItemId() -> Int {
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let itemId: Int = userDefaults.integerForKey("ChecklistItemId")
        userDefaults.setInteger(itemId + 1, forKey: "ChecklistItemId")
        userDefaults.synchronize()
        return itemId
    }

    ///register defaults for the application. We declare yes to firsttime and id for location notification to zero.
    func registerDefaults() {
        let dictionary: [NSObject : AnyObject] = [
                "FirstTime" : Int(true),
                "ChecklistItemId" : Int(0)
            ]

        NSUserDefaults.standardUserDefaults().registerDefaults(dictionary)
    }
    ///When the app run first time, we need to change the user default for "firstrun" to NO.

    func handleFirstTime() {
        let firstTime: Bool = NSUserDefaults.standardUserDefaults().boolForKey("FirstTime")
        if firstTime {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "FirstTime")
        }
    }
    ///Once loaded we call the following methods to check whether first time or subsequent time loading.

    convenience override init() {
        if (self.init()) {
            self.registerDefaults()
            self.handleFirstTime()
        }
    }
    ///Here we assign the ID for first checklist createdto 0 and for each checklist generated subsequently will add  incremental of 1.
}