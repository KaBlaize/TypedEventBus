import XCTest
import Combine
@testable import SwitEventType

final class SwitEventTypeTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    func testWithEvent() throws {
        let callExpectation = XCTestExpectation(description: "subscribe called")

        let loginEvent = LoginEvent()
        let stateChangedEvent = ApplicationStateChangedEvent()
        loginEvent.subscribeEvent { event in
            XCTAssertEqual(event.object?.name ?? "", "Joe")
            callExpectation.fulfill()
        }.store(in: &cancellables)


        stateChangedEvent.post(.authenticated)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            //        loginEvent.post(LoginEvent(Person(name: "Joe")))
            loginEvent.post(Person(name: "Joe"))
        }

        wait(for: [callExpectation], timeout: 2)
    }

    func testWithEventBus() {
        let callExpectation = XCTestExpectation(description: "subscribe called")

        let eventBus = TypedEventBus()
        eventBus.subscribe(to: LoginEvent.self) { object in
            XCTAssertEqual(object.name, "Joe")
            callExpectation.fulfill()
        }.store(in: &cancellables)

        eventBus.post(ApplicationStateChangedEvent(.authenticated))
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            eventBus.post(LoginEvent(Person(name: "Joe")))
        }
        wait(for: [callExpectation], timeout: 2)
    }
}
