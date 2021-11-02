import Foundation
import Combine

protocol EventSubscriberDataSource: AnyObject {
    var queue: DispatchQueue { get set }

    func deleteAllSubscribers()
}

final class TypedEventSubscriberRepository<TypedEvent>: EventSubscriberDataSource {
    // MARK: - Private Type declarations

    private typealias Subscriber = String

    private struct Subscription {
        var subscriber: Subscriber
        let closure: (TypedEvent) -> Void
    }

    // MARK: - Properties

    private var subscriptions: [Subscription] = []
    var queue: DispatchQueue

    // MARK: - Lifecycle

    init(queue: DispatchQueue = DispatchQueue(label: "TypedEventSubscriberDataSource-\(TypedEvent.self)", qos: .background)) {
        self.queue = queue
    }
}

// MARK: - Public functions

extension TypedEventSubscriberRepository {
    final func addEvent(_ event: TypedEvent) {
        addToQueue(type: .eventDispatch) { [weak self] in
            guard let self = self else { return }
            self.subscriptions.forEach { $0.closure(event) }
        }
    }

    final func addSubscriber(_ closure: @escaping (TypedEvent) -> Void) -> AnyCancellable {
        let subscriber = UUID().uuidString
        addToQueue { [weak self] in
            guard let self = self else { return }
            self.subscriptions = self.subscriptions + [Subscription(subscriber: subscriber, closure: closure)]
        }
        return AnyCancellable { [weak self] in
            self?.unsubscribe(subscriber)
        }
    }

    final func deleteAllSubscribers() {
        addToQueue { [weak self] in
            guard let self = self else { return }
            self.subscriptions = []
        }
    }
}

// MARK: - Private functions

private extension TypedEventSubscriberRepository {
    private enum OperationType {
        case subscriptionChange, eventDispatch
    }

    final private func addToQueue(type: OperationType = .subscriptionChange, _ task: @escaping () -> Void) {
        queue.async {
            task()
        }
    }

    final private func unsubscribe(_ subscriber: Subscriber) {
        addToQueue { [weak self] in
            guard let self = self, self.subscriptions.count > 0 else { return }
            self.subscriptions = self.subscriptions.filter { $0.subscriber != subscriber }
        }
    }
}
