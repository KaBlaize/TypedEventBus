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
        let callExpectationLogout2 = XCTestExpectation(description: "subscribe called - logout2")

        let eventBus = TypedEventBus()
        eventBus.subscribe(to: LoginEvent.self) { object in
            XCTAssertEqual(object.name, "Joe")
            callExpectationLogin.fulfill()
        }.store(in: &cancellables)

        eventBus.subscribe(to: LogoutEvent.self) { person in
            XCTAssertEqual(person.name, "Mary")
            callExpectationLogout.fulfill()
        }.store(in: &cancellables)

        eventBus.subscribe(to: LogoutEvent.self) { person in
            XCTAssertEqual(person.name, "Mary")
            callExpectationLogout2.fulfill()
        }.store(in: &cancellables)

        eventBus.post(ApplicationStateChangedEvent(.authenticated))
        eventBus.post(LogoutEvent(Person(name: "Mary")))
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            eventBus.post(LoginEvent(Person(name: "Joe")))
        }
        wait(for: [callExpectationLogout, callExpectationLogin], timeout: 2)
    }

    func testPerformance() {
        let eventBus = TypedEventBus()
        let subscriptionNbr = 1000
        let postingNbr = 200
        measure {
            var expectations = [XCTestExpectation]()
            func subscribe<O, Event: TypedEvent<O>>(to event: Event.Type) {
                let expectation = XCTestExpectation()
                expectations.append(expectation)
                eventBus.subscribe(to: Event.self) { _ in
                    expectation.fulfill()
                }.store(in: &cancellables)
            }
            for _ in 0..<subscriptionNbr {
                subscribe(to: LoginEvent.self)
                subscribe(to: LogoutEvent.self)
                subscribe(to: ApplicationStateChangedEvent.self)
            }
            for _ in 0..<postingNbr {
                eventBus.post(LoginEvent(Person(name: "Jyx")))
                eventBus.post(ApplicationStateChangedEvent(.authenticated))
                eventBus.post(LogoutEvent(Person(name: "Jane")))
            }
            wait(for: expectations, timeout: 30)
        }
    }
}
