import Foundation

/// 类型协议
protocol TypeWrapperProtocol {
    associatedtype WrappedType
    var wrappedValue: WrappedType { get }
    init(value: WrappedType)
}

struct NamespaceWrapper<T>: TypeWrapperProtocol {
    let wrappedValue: T
    init(value: T) {
        self.wrappedValue = value
    }
}

protocol NamespaceWrappable {
    associatedtype WrapperType
    var ll: WrapperType { get }
    static var ll: WrapperType.Type { get }
}

extension NamespaceWrappable {
    var ll: NamespaceWrapper<Self> {
        return NamespaceWrapper(value: self)
    }
    static var ll: NamespaceWrapper<Self>.Type {
        return NamespaceWrapper.self
    }
}
