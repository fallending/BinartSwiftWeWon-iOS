import Foundation

public extension String {
    func ba_isLikePhoneNumber() -> Bool {
        let p = "^1[0-9]{10}$"
        
        if NSPredicate(format: "SELF MATCHES %@", p).evaluate(with: self) {
            return true
        }
        
        return false
    }
    
    func ba_toInt64 () -> Int64 {
        let strNS = self as NSString
        
        return strNS.longLongValue
    }
    
    func ba_toDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func ba_toNSNumber () -> NSNumber? {
        if let i = Int(self) {
            return NSNumber(value: i)
        }
        
        return nil
    }
}
