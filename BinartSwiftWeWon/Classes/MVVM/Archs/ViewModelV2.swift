import UIKit

typealias ActionCompletionFunc<T> = (_ action: T, _ res: Any?, _ err: Int?, _ msg: String?) -> Void

open class ViewModelV2<T: ViewAction>: NSObject { // 继承自 NSObject，方便它的派生类实现@objc protocol
    
    var isMock: Bool?
    var title: String?
    
    var observer: ActionCompletionFunc<T>?
    
    //
    required public override init () {
        super.init()
        
        onCreate()
    }
    
    deinit {
        onDestory()
    }
    
    // MARK: = VC's Lifecycle
    
    public func onCreate () {}
    public func onLoad () {}
    
    public func willAppear() {}
    public func didAppear () {}
    
    public func willDisappear () {}
    public func didDisappear () {}
    
    public func onDestory () {}
    
    // MARK: = Action handler
    
    /// PULL 模式
    
    final func handle(_ action: T) -> Void {
        handle(action, params: nil, callback: {_,_,_ in })
    }
    
    final func handle(_ action: T, params: Any?) -> Void {
        handle(action, params: params, callback: {_,_,_ in })
    }
    
    final func handle(_ action: T, callback: @escaping CompletionFunc) -> Void {
        handle(action, params: nil, callback: callback)
    }
    
    func handle(_ action: T, params: Any?, callback: @escaping CompletionFunc) -> Void {
        
    }
    
    // MARK: = Data Observer
    
    /// PUSH模式：VC 主动监测 VM，VM主动向VC推数据
    
    func observe(_ callback: @escaping ActionCompletionFunc<T>) {
        observer = callback
    }
    
    func notify(_ action: T, res: Any?, err: Int?, msg: String? , callback: CompletionFunc? = nil) {
        // 优先通知callback
        callback?(res, err, msg)
        
        // 其次通知observer
        observer?(action, res, err, msg)
    }
    
    // MARK: = UITableView DataSouce
    
    func modelWithIndexPath(indexPath: IndexPath) -> Any {
        return ""
    }
    
    func dataModelWithIndexPath(indexPath: IndexPath) -> Any {
        return ""
    }
    
    func numberOfSections() -> Int {
        return 0
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return 0
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        return ""
    }
    
    func sectionIndexTitles() -> [String]? {
        return []
    }
    
    // MARK: = 工具方法
    
    func noop() {
        
    }
}
