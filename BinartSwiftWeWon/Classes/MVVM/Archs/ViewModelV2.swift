import UIKit

public typealias ActionCompletionFunc<T> = (_ action: T, _ res: Any?, _ err: Int?, _ msg: String?) -> Void

open class ViewModelV2<T: ViewAction>: NSObject { // 继承自 NSObject，方便它的派生类实现@objc protocol
    
    public var isMock: Bool?
    public var title: String?
    
    public var observer: ActionCompletionFunc<T>?
    
    //
    required public override init () {
        super.init()
        
        onCreate()
    }
    
    deinit {
        onDestory()
    }
    
    // MARK: = VC's Lifecycle
    
    open func onCreate () {}
    open func onLoad () {}
    
    open func willAppear() {}
    open func didAppear () {}
    
    open func willDisappear () {}
    open func didDisappear () {}
    
    open func onDestory () {}
    
    // MARK: = Action handler
    
    /// PULL 模式
    
    final public func handle(_ action: T) -> Void {
        handle(action, params: nil, callback: {_,_,_ in })
    }
    
    final public func handle(_ action: T, params: Any?) -> Void {
        handle(action, params: params, callback: {_,_,_ in })
    }
    
    final public func handle(_ action: T, callback: @escaping CompletionFunc) -> Void {
        handle(action, params: nil, callback: callback)
    }
    
    open func handle(_ action: T, params: Any?, callback: @escaping CompletionFunc) -> Void {
        
    }
    
    // MARK: = Data Observer
    
    /// PUSH模式：VC 主动监测 VM，VM主动向VC推数据
    
    open func observe(_ callback: @escaping ActionCompletionFunc<T>) {
        observer = callback
    }
    
    public func notify(_ action: T, res: Any?, err: Int?, msg: String? , callback: CompletionFunc? = nil) {
        // 优先通知callback
        callback?(res, err, msg)
        
        // 其次通知observer
        observer?(action, res, err, msg)
    }
}
