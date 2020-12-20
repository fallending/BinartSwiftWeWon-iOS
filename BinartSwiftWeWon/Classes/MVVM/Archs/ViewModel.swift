import Foundation

public class ViewModel: NSObject { // 继承自 NSObject，方便它的派生类实现@objc protocol
    
    var isMock: Bool?
    var title: String?
    
    var onDataUpdatedHandler: CompletionFunc?
    
    //

    required override init () {
        super.init()
    
        onCreate()
    }
    
    deinit {
        onDestory()
    }
    
    //
    
    @available(*, deprecated, message: "Use onload instead")
    public func setup() {
        
    }
    
    @available(*, deprecated, message: "Use onDestory instead")
    public func setdown () {
        
    }
    
    public func preLoad () {}
    
    // MARK: = VS's Lifecycle
    
    public func onCreate () {} // FIXME: -> onViewCreate，以下同上
    public func onLoad () {}
    
    public func willAppear() {}
    public func didAppear () {}
    
    public func willDisappear () {}
    public func didDisappear () {}
    
    public func onDestory () {}
    
    // MARK: = Action handler
    
    final func handle(_ action: ViewAction) -> Void {
        handle(action, params: nil, callback: {_,_,_ in })
    }
    
    final func handle(_ action: ViewAction, params: Any?) -> Void {
        handle(action, params: params, callback: {_,_,_ in })
    }
    
    final func handle(_ action: ViewAction, callback: @escaping CompletionFunc) -> Void {
        handle(action, params: nil, callback: callback)
    }
    
    func handle(_ action: ViewAction, params: Any?, callback: @escaping CompletionFunc) -> Void {
        
    }
    
    // MARK: = Data Observer
    
    func observe(_ action: ViewAction, callback: @escaping CompletionFunc) {
        
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
    
    // MARK: =
    
    func noop() {
        
    }
}
