import Foundation
import UIKit
import GKNavigationBarSwift

/// 范型继承，下一级继承需要特化（终止范型链）
class ViewCtrlV2<A: ViewAction, T: ViewModelV2<A>>: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    var navHidden = false
    
    var viewModel: T!
    
    // MARK: - Initializers
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel?.onDestory()
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDefault()
        
        setupUI()
        
        setupVM()
        
        viewModel?.onLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = prefersNavigationBarHidden
        
        viewModel.willAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 侧滑配置
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        viewModel.didAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.willDisappear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = !prefersNavigationBarHidden
        
        viewModel.didDisappear()
    }
    
    // MARK: = Api Setup
    
    open var prefersNavigationBarHidden: Bool {
        return false;
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.gk_statusBarHidden
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.gk_statusBarStyle
    }
    
    // MARK: - Custom Setup
    
    private func setupDefault () {
        self.modalPresentationStyle = .fullScreen
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.gk_navigationBar.isHidden = prefersNavigationBarHidden
        self.gk_navBackgroundColor = .blue
        self.gk_statusBarStyle = .lightContent
        self.gk_navTitleFont = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        self.gk_navTitleColor = .blue
        self.gk_navLineHidden = true
        self.gk_backImage = #imageLiteral(resourceName: "ic_arrow_left")
        
        self.title = viewModel.title
        self.gk_navTitle = self.title
    }
    
    open func setupUI () {
        
    }
    
    open func setupCollectionView () {
        
    }
    
    open func setupTableView () {
        
    }
    
    open func setupVM () {
        viewModel?.observer = {[weak self] (action, res, err, msg) in
            self?.onNotify(action, res: res, err: err, msg: msg)
        }
    }
    
    open func onNotify(_ action: A, res: Any?, err: Int?, msg: String?) {
        
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: - Router (register, routeToURL, scene <- sceneURL <- Action)
    
    // scene 50 +
    // tabbar
    // tab1: a -> b -> c -> d -> e | -> b -> a -> .... tab2
    // tab2: h ->
    
    
    // MARK: - Navigation/Presentation
    
    func push(_ viewCtrl: UIViewController) {
        navigationController?.pushViewController(viewCtrl, animated: true);
    }
    
    func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: -
    
    func withViewModel(clzz: T.Type) -> Self {
        viewModel = clzz.init()
        
        viewModel.onCreate() // 底层事件，已经可以向VM发送，如果vc中需要用的viewmodel，还是需要给viewModel赋值
        
        return self
    }
}