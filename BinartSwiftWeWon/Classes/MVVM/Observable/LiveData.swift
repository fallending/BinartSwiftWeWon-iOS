import Foundation

// 运算符重载 ~> 绑定

//viewModel.title ~> titleLabel
//viewModel.gameList ~> gameListTableView
//viewModel.roleList ~> roleListCollectionView

// 命名很差
class LiveData<T> {

    var value: T? {
        didSet {
            for listener in listeners {
                listener(value)
            }
        }
    }

    private var listeners: [((T?) -> Void)] = []

    init() {
        
    }
    
    init(_ value: T) {
        self.value = value
    }

    func on(_ closure: @escaping (T?) -> Void) {
        closure(value)
        
        listeners.append(closure)
    }
    
    func set(_ value: T?) {
        self.value = value
    }
}


protocol MVVMObservableViewModelProtocol {
    func fetchEmployees()
    func setError(_ message: String)
    var employees: LiveData<[NSObject]> { get  set } //1
    var errorMessage: LiveData<String?> { get set }
    var error: LiveData<Bool> { get set }
}

//class ObservableViewModel: ObservableViewModelProtocol {
//    var errorMessage: Observable<String?> = Observable(nil)
//    var error: Observable<Bool> = Observable(false)
//
//    var apiManager: APIManager?
//    var employees: Observable<[Employee]> = Observable([]) //2
//    init(manager: APIManager = APIManager()) {
//        self.apiManager = manager
//    }
//
//    func setAPIManager(manager: APIManager) {
//        self.apiManager = manager
//    }
//
//    func fetchEmployees() {
//        self.apiManager!.getEmployees { (result: DataResponse<EmployeesResponse, AFError>) in
//            switch result.result {
//            case .success(let response):
//                if response.status == "success" {
//                    self.employees = Observable(response.data) //3
//                    return
//                }
//                self.setError(BaseNetworkManager().getErrorMessage(response: result))
//            case .failure:
//                self.setError(BaseNetworkManager().getErrorMessage(response: result))
//            }
//        }
//    }
//
//    func setError(_ message: String) {
//        self.errorMessage = Observable(message)
//        self.error = Observable(true)
//    }
//
//}


/********* Binding to array in viewDidLoad */
// viewModel.employees.on { (_) in
//   self.showTableView()
// }
/********************************/
