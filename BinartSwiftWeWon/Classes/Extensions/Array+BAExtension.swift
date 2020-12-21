import Foundation

public extension Array {
    
    /// 数组是否包含字符串
    func ba_containsString (aString: String) -> Bool {
        return self.contains(where: {
            if let str = $0 as? String {
                return str == aString
            }
            
            return false
        })
    }
    
    /// 数组是否包含字符串，且忽略大小写
    func ba_containsStringIgnoreCases (aString: String) -> Bool {
        return self.contains(where: {
            if let str = $0 as? String {
                return str.caseInsensitiveCompare(aString) == .orderedSame
            }
            
            return false
        })
    }
    
    /// 去重
    func ba_filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
}
