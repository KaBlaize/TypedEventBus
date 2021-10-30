import Foundation
import Combine

public class TypedEventBus {
    private var events = [BaseTypedEvent]()

    public init() {}

    public func post<O, Event: TypedEvent<O>>(_ postedEvent: Event) {
        guard let event = events.first(where: { $0 as? Event != nil }) as? Event else { return }
        event.post(postedEvent)
    }

    public func subscribeEvent<T: TypedEvent.Subscriber & Equatable, O, Event: TypedEvent<O>>(to eventType: Event.Type, _ subscriber: T, _ closure: @escaping (Event) -> Void) -> AnyCancellable {
        let event = getOrCreateEvent(for: eventType)
        return event.subscribeEvent(subscriber) { event in
            closure(event as! Event)
        }
    }

    public func subscribe<T: TypedEvent.Subscriber & Equatable, O, Event: TypedEvent<O>>(to eventType: Event.Type, _ subscriber: T, _ closure: @escaping (O) -> Void) -> AnyCancellable {
        let event = getOrCreateEvent(for: eventType)
        return event.subscribeEvent(subscriber) { event in
            guard let object = event.object else { return }
            closure(object)
        }
    }

    private func getOrCreateEvent<O, Event: TypedEvent<O>>(for type: Event.Type) -> Event {
        if let event = events.first(where: { $0 as? Event != nil }) as? Event {
            return event
        } else {
            let event = Event()
            events.append(event)
            return event
        }
    }
}
