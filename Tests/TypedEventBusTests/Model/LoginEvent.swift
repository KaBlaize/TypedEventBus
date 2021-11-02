import Foundation
import TypedEventBus

final class LoginEvent: TypedEvent<Person> {
    let extraProperty = "extra"
}
