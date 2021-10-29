import Foundation
import Combine

public class TypedEventBus {
    private var events = [BaseTypedEvent]()

    public init() {}

    public func post<O, Event: TypedEvent<O>>(_ postedEvent: Event) {
        guard let event = events.first(where: { $0 as? Event != nil }) as? Event else { return }
        event.post(postedEvent)
    }

    public func subscribe<T: TypedEvent.Subscriber & Equatable, O, Event: TypedEvent<O>>(to eventType: Event.Type, _ subscriber: T, _ closure: @escaping (Event) -> Void) -> AnyCancellable {
        if let event = events.first(where: { $0 as? Event != nil }) as? Event {
            return event.subscribe(subscriber) { event in
                closure(event as! Event)
            }
        } else {
            let event = Event()
            events.append(event)
            return event.subscribe(subscriber) { event in
                closure(event as! Event)
            }
        }

    }
}
