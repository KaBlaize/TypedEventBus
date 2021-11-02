import Foundation
import Combine

open class TypedEventBus {
    // MARK: - Properties

    public static let main = TypedEventBus()
    public var queue: DispatchQueue {
        didSet {
            subscriberStores.forEach { $0.queue = queue }
        }
    }
    private var subscriberStores = [EventSubscriberDataSource]()

    // MARK: - Lifecycle

    public init(queue: DispatchQueue = DispatchQueue(label: "TypedEventBus")) {
        self.queue = queue
    }
}

// MARK: - Public functions

extension TypedEventBus {
    open func post<O, Event: TypedEvent<O>>(_ event: Event) {
        getOrCreateSubscriberDataSource(for: Event.self).addEvent(event)
    }

    open func subscribeEvent<O, Event: TypedEvent<O>>(to eventType: Event.Type, _ closure: @escaping (Event) -> Void) -> AnyCancellable {
        getOrCreateSubscriberDataSource(for: Event.self).addSubscriber(closure)
    }

    open func subscribe<O, Event: TypedEvent<O>>(to eventType: Event.Type, _ closure: @escaping (O) -> Void) -> AnyCancellable {
        getOrCreateSubscriberDataSource(for: Event.self)
            .addSubscriber { event in
                guard let object = event.object else { return }
                closure(object)
            }
    }

    open func reset() {
        subscriberStores.forEach { $0.deleteAllSubscribers() }
    }
}

// MARK: - Private functions

extension TypedEventBus {
    final private func getOrCreateSubscriberDataSource<O, Event: TypedEvent<O>, DataStore: TypedEventSubscriberRepository<Event>>(for type: Event.Type) -> DataStore {
        if let dataStore = subscriberStores.first(where: { $0 as? DataStore != nil }) as? DataStore {
            return dataStore
        } else {
            let dataStore = DataStore(queue: queue)
            subscriberStores.append(dataStore)
            return dataStore
        }
    }
}
