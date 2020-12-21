import Foundation

open class ViewModel: NSObject { // 继承自 NSObject，方便它的派生类实现@objc protocol
    
    public var isMock: Bool?
    public var title: String?
    
    public var onDataUpdatedHandler: CompletionFunc?
    
    //

    required public override init () {
        super.init()
    
        onCreate()
    }
    
    deinit {
        onDestory()
    }
    
    open func preLoad () {}
    
    // MARK: = VS's Lifecycle
    
    open func onCreate () {} // FIXME: -> onViewCreate，以下同上
    open func onLoad () {}
    
    open func willAppear() {}
    open func didAppear () {}
    
    open func willDisappear () {}
    open func didDisappear () {}
    
    open func onDestory () {}
    
    // MARK: = Action handler
    
    final public func handle(_ action: ViewAction) -> Void {
        handle(action, params: nil, callback: {_,_,_ in })
    }
    
    final public func handle(_ action: ViewAction, params: Any?) -> Void {
        handle(action, params: params, callback: {_,_,_ in })
    }
    
    final public func handle(_ action: ViewAction, callback: @escaping CompletionFunc) -> Void {
        handle(action, params: nil, callback: callback)
    }
    
    open func handle(_ action: ViewAction, params: Any?, callback: @escaping CompletionFunc) -> Void {
        
    }
    
    // MARK: = Data Observer
    
    open func observe(_ action: ViewAction, callback: @escaping CompletionFunc) {
        
    }
}
