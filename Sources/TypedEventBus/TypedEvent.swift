import Foundation
import Combine

public protocol BaseTypedEvent: AnyObject {}

open class TypedEvent<Object>: BaseTypedEvent {
    public private(set) var object: Object?

    private lazy var subscriberStore = TypedEventSubscriberDataSource<TypedEvent<Object>>()

    public init() {}

    public init(_ object: Object) {
        self.object = object
    }

    public func post(_ object: Object) {
        self.object = object
        subscriberStore.post(self)
    }

    public func subscribeEvent(_ closure: @escaping (TypedEvent<Object>) -> Void) -> AnyCancellable {
        subscriberStore.subscribeEvent(closure)
    }

    public func subscribe(_ closure: @escaping (Object) -> Void) -> AnyCancellable {
        subscriberStore.subscribeEvent({ event in
            guard let object = event.object else { return }
            closure(object)
        })
    }
}
