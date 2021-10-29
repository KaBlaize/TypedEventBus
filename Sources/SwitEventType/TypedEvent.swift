import Foundation
import Combine

public protocol BaseTypedEvent: AnyObject {}

open class TypedEvent<Object>: BaseTypedEvent {
    public typealias Subscriber = AnyObject

    private struct WeakSubscriber {
        weak var subscriber: Subscriber?
        let closure: (TypedEvent<Object>) -> Void
    }

    private lazy var subscribers: [WeakSubscriber] = []
    public private(set) var object: Object?

    public required init() {}

    public init(_ object: Object) {
        self.object = object
    }

    public func post(_ object: TypedEvent) {
        subscribers.forEach {
            $0.closure(object)
        }
    }

    public func post(_ object: Object) {
        self.object = object
        subscribers.forEach {
            $0.closure(self)
        }
    }

    public func subscribe<T: Subscriber & Equatable>(_ subscriber: T, _ closure: @escaping (TypedEvent<Object>) -> Void) -> AnyCancellable {
        cleanup()
        subscribers.append(WeakSubscriber(subscriber: subscriber, closure: closure))
        return AnyCancellable { [weak self] in
            self?.unsubscribe(subscriber)
        }
    }

    public func unsubscribe<T: Subscriber & Equatable>(_ subscriber: T) {
        cleanup()
        subscribers = subscribers.filter {
            guard let current = $0.subscriber as? T else { return true }
            return current != subscriber
        }
    }

    private func cleanup() {
        subscribers =  subscribers.filter { $0.subscriber != nil }
    }
}
