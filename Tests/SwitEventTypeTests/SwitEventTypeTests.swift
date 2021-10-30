import XCTest
import Combine
@testable import SwitEventType

final class SwitEventTypeTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    func testWithEvent() throws {
        let callExpectation = XCTestExpectation(description: "subscribe called")

        let loginEvent = LoginEvent()
        loginEvent.subscribeEvent(self) { event in
            XCTAssertEqual(event.object?.name ?? "", "Joe")
            callExpectation.fulfill()
        }.store(in: &cancellables)

//        loginEvent.post(LoginEvent(Person(name: "Joe")))
        loginEvent.post(Person(name: "Joe"))

        wait(for: [callExpectation], timeout: 200)
    }

    func testWithEventBus() {
        let callExpectation = XCTestExpectation(description: "subscribe called")

        let eventBus = TypedEventBus()
        eventBus.subscribe(to: LoginEvent.self, self) { object in
            XCTAssertEqual(object.name, "Joe")
            callExpectation.fulfill()
        }.store(in: &cancellables)

        eventBus.post(LoginEvent(Person(name: "Joe")))

        wait(for: [callExpectation], timeout: 200)
    }
}
