import Foundation

// MARK: - 取值

public extension Dictionary {
    func ba_string(for key: String) -> String? {
        if let dict = self as? [String: Any] {
            return (dict[key] as? String) ?? nil
        }
        
        return nil
    }
    
    func ba_string(for key: String, or: String) -> String {
        let r = ba_string(for: key)
        
        return r ?? or
    }
}

// MARK: - 转化

public extension Dictionary {
    func ba_toQuery () -> String {
        var output: String = ""
        for (key,value) in self {
            output +=  "\(key)=\(value)&"
        }
        output = String(output.dropLast())
        
        return output
    }
    
    func ba_toString () -> String? {
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: self,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                       encoding: .ascii)
            return theJSONText
        }
        
        return nil
    }
}
