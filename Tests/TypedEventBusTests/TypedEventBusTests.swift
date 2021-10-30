import XCTest
import Combine
@testable import TypedEventBus

final class TypedEventBusTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    func testWithEvent() throws {
        let callExpectationLogin = XCTestExpectation(description: "subscribe called - login")
        let callExpectationLogout = XCTestExpectation(description: "subscribe called - logout")

        let loginEvent = LoginEvent()
        let stateChangedEvent = ApplicationStateChangedEvent()
        let logoutEvent = LogoutEvent()
        loginEvent.subscribeEvent { event in
            XCTAssertEqual(event.object?.name ?? "", "Joe")
            callExpectationLogin.fulfill()
        }.store(in: &cancellables)

        logoutEvent.subscribeEvent { event in
            XCTAssertEqual(event.object?.name ?? "", "Martin")
            callExpectationLogout.fulfill()
        }.store(in: &cancellables)


        stateChangedEvent.post(.authenticated)
        logoutEvent.post(Person(name: "Martin"))
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            loginEvent.post(Person(name: "Joe"))
        }

        wait(for: [callExpectationLogout, callExpectationLogin], timeout: 2)
    }

    func testWithEventBus() {
        let callExpectationLogin = XCTestExpectation(description: "subscribe called - login")
        let callExpectationLogout = XCTestExpectation(description: "subscribe called - logout")

        let eventBus = TypedEventBus()
        eventBus.subscribe(to: LoginEvent.self) { object in
            XCTAssertEqual(object.name, "Joe")
            callExpectationLogin.fulfill()
        }.store(in: &cancellables)

        eventBus.subscribe(to: LogoutEvent.self) { person in
            XCTAssertEqual(person.name, "Mary")
            callExpectationLogout.fulfill()
        }.store(in: &cancellables)

        eventBus.post(ApplicationStateChangedEvent(.authenticated))
        eventBus.post(LogoutEvent(Person(name: "Mary")))
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            eventBus.post(LoginEvent(Person(name: "Joe")))
        }
        wait(for: [callExpectationLogout, callExpectationLogin], timeout: 2)
    }
}
