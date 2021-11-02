import Foundation
import Combine

protocol EventSubscriberDataSource: AnyObject {
    var queue: DispatchQueue { get set }

    func reset()
}

final class TypedEventSubscriberDataSource<TypedEvent>: EventSubscriberDataSource {
    private typealias Subscriber = String

    private struct Subscription {
        var subscriber: Subscriber
        let closure: (TypedEvent) -> Void
    }

    private var bus: TypedEventBus { TypedEventBus.main }
    private var subscribers: [Subscription] = []
    var queue: DispatchQueue

    init() {
        queue = DispatchQueue(label: "TypedEventSubscriberDataSource-\(TypedEvent.self)", qos: .background)
    }

    final func post(_ object: TypedEvent) {
        addToQueue(type: .post) { [weak self] in
            guard let self = self else { return }
            self.subscribers.forEach { $0.closure(object) }
        }
    }

    final func subscribeEvent(_ closure: @escaping (TypedEvent) -> Void) -> AnyCancellable {
        let subscriber = UUID().uuidString
        addToQueue { [weak self] in
            guard let self = self else { return }
            self.subscribers = self.subscribers + [Subscription(subscriber: subscriber, closure: closure)]
        }
        return AnyCancellable { [weak self] in
            self?.unsubscribe(subscriber)
        }
    }

    final func reset() {
        addToQueue { [weak self] in
            guard let self = self else { return }
            self.subscribers = []
        }
    }

    final private func unsubscribe(_ subscriber: Subscriber) {
        addToQueue { [weak self] in
            guard let self = self, self.subscribers.count > 0 else { return }
            self.subscribers = self.subscribers.filter { $0.subscriber != subscriber }
        }
    }
}

private extension TypedEventSubscriberDataSource {
    private enum OperationType {
        case subscription, post
    }

    private final func addToQueue(type: OperationType = .subscription, _ task: @escaping () -> Void) {
        queue.async {
            task()
        }
    }
}
