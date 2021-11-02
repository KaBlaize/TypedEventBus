import Foundation
import Combine

open class TypedEventBus {
    // MARK: - Properties

    public static let main = TypedEventBus()
    public var queue: DispatchQueue? {
        get {
            subscriberStores.first?.queue
        } set {
            guard let queue = newValue else { return }
            subscriberStores.forEach { $0.queue = queue }
        }
    }
    private var subscriberStores = [EventSubscriberDataSource]()

    // MARK: - Lifecycle

    public init() {}
}

// MARK: - Public functions

extension TypedEventBus {
    open func post<O, Event: TypedEvent<O>>(_ event: Event) {
        getOrCreateSubscriberDataSource(for: Event.self).post(event)
    }

    open func subscribeEvent<O, Event: TypedEvent<O>>(to eventType: Event.Type, _ closure: @escaping (Event) -> Void) -> AnyCancellable {
        getOrCreateSubscriberDataSource(for: Event.self).subscribeEvent(closure)
    }

    open func subscribe<O, Event: TypedEvent<O>>(to eventType: Event.Type, _ closure: @escaping (O) -> Void) -> AnyCancellable {
        getOrCreateSubscriberDataSource(for: Event.self)
            .subscribeEvent { event in
                guard let object = event.object else { return }
                closure(object)
            }
    }

    open func reset() {
        subscriberStores.forEach { $0.reset() }
    }
}

// MARK: - Private functions

extension TypedEventBus {
    final private func getOrCreateSubscriberDataSource<O, Event: TypedEvent<O>, DataStore: TypedEventSubscriberDataSource<Event>>(for type: Event.Type) -> DataStore {
        if let dataStore = subscriberStores.first(where: { $0 as? DataStore != nil }) as? DataStore {
            return dataStore
        } else {
            let dataStore = DataStore()
            subscriberStores.append(dataStore)
            return dataStore
        }
    }
}
