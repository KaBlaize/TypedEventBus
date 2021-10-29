import XCTest
import Combine
@testable import SwitEventType

final class SwitEventTypeTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    func testWithEvent() throws {
        let callExpectation = XCTestExpectation(description: "subscribe called")

        let loginEvent = LoginEvent()
        loginEvent.subscribe(self) { object in
            XCTAssertEqual(object.name, "Joe")
            callExpectation.fulfill()
        }.store(in: &cancellables)

        loginEvent.post(Person(name: "Joe"))
        wait(for: [callExpectation], timeout: 200)
    }
}
