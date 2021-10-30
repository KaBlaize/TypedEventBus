import Foundation
import Combine

open class TypedEventBus {
    private var subscriberStores = [EventSubscriberDataSource]()

    public init() {}

    open func post<O, Event: TypedEvent<O>>(_ event: Event) {
        let store = getOrCreateSubscriberDataSource(for: Event.self)
        store.post(event)
    }

    open func subscribeEvent<O, Event: TypedEvent<O>>(to eventType: Event.Type, _ closure: @escaping (Event) -> Void) -> AnyCancellable {
        let store = getOrCreateSubscriberDataSource(for: Event.self)
        return store.subscribeEvent(closure)
    }

    open func subscribe<O, Event: TypedEvent<O>>(to eventType: Event.Type, _ closure: @escaping (O) -> Void) -> AnyCancellable {
        let store = getOrCreateSubscriberDataSource(for: Event.self)
        return store.subscribeEvent { event in
            guard let object = event.object else { return }
            closure(object)
        }
    }

    private func getOrCreateSubscriberDataSource<O, Event: TypedEvent<O>, DataStore: TypedEventSubscriberDataSource<Event>>(for type: Event.Type) -> DataStore {
        if let dataStore = subscriberStores.first(where: { $0 as? DataStore != nil }) as? DataStore {
            return dataStore
        } else {
            let dataStore = DataStore()
            subscriberStores.append(dataStore)
            return dataStore
        }
    }
}
