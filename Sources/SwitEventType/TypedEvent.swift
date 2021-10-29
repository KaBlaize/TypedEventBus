import Foundation
import Combine

public protocol BaseTypedEvent: class {}

open class TypedEvent<Object>: BaseTypedEvent {
    public typealias Subscriber = AnyObject
    private struct WeakSubscriber {
        weak var subscriber: Subscriber?
        let closure: (Object) -> Void
    }

    private lazy var subscribers: [WeakSubscriber] = []

    public init() {}

    public func post(_ object: Object) {
        subscribers.forEach {
            $0.closure(object)
        }
    }

    public func subscribe<T: Subscriber & Equatable>(_ subscriber: T, _ closure: @escaping (Object) -> Void) -> AnyCancellable {
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
