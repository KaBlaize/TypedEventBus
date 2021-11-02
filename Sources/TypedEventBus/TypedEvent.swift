import Foundation

public protocol BaseTypedEvent: AnyObject {}

open class TypedEvent<Object>: BaseTypedEvent {
    public private(set) var object: Object?

    public init() {}

    public init(_ object: Object) {
        self.object = object
    }
}
