import Foundation
import Combine

protocol EventSubscriberDataSource: AnyObject {}

final class TypedEventSubscriberDataSource<TypedEvent>: EventSubscriberDataSource {
    private typealias Subscriber = String
    private struct Subscription {
        var subscriber: Subscriber
        let closure: (TypedEvent) -> Void
    }

    private lazy var subscribers: [Subscription] = []

    func post(_ object: TypedEvent) {
        subscribers.forEach {
            $0.closure(object)
        }
    }

    func subscribeEvent(_ closure: @escaping (TypedEvent) -> Void) -> AnyCancellable {
        let subscriber = UUID().uuidString
        subscribers.append(Subscription(subscriber: subscriber, closure: closure))
        return AnyCancellable { [weak self] in
            self?.unsubscribe(subscriber)
        }
    }

    private func unsubscribe(_ subscriber: Subscriber) {
        subscribers = subscribers.filter { $0.subscriber != subscriber }
    }
}
