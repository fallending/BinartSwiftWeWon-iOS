import Foundation


//业务码
public let SUCCESS = 0
public let FAILURE = -1

public typealias CompletionFunc = (_ resp: Any?, _ err: Int?, _ msg: String?) -> Void
public typealias SuccessFunc = (_ resp: Any?) -> Void
public typealias FailureFunc = (_ err: Int, _ msg: String?) -> Void
public typealias StringFunc = (_ text: String) -> Void
public typealias VoidFunc = () -> Void
public typealias DoneFunc = (_ resp: Any?) -> Void
public typealias BoolFunc = (_ value: Bool) -> Void
public typealias IntFunc = (_ value: Int) -> Void


// FIXME: 丑陋！！！！草！
public typealias StringTuple = (_: String?)
public typealias StringDictionaryTuple = (_: String?, _:  [AnyHashable : Any]?)
public typealias URLTuple = (_: URL?)
public typealias StringFloatTuple = (_: String?, _: Float?)
// content: String, id: Int64, path: String, url: String) {
public typealias StringInt64StringStringTuple = (_: String, _: Int64, _: String, _: String)
public typealias String2Tuple = (_: String?, _: String?)
public typealias OptionalString2Tuple = (_: String?, _: String?)
public typealias StringInt2Tuple = (_: String?, _: Int?)
public typealias StringInt3Tuple = (_: String?, _: Int?, _: Int?)
public typealias String2IntTuple = (_: String?, _: String?, _: Int64?)
public typealias IntTuple = (_: Int)
