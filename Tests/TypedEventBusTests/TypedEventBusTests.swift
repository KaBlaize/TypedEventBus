import XCTest
import Combine
@testable import TypedEventBus

final class TypedEventBusTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    private var timeout: TimeInterval = 10
    private let numberOfIterations = 1000

    override func setUp() {
        cancellables = []
        TypedEventBus.main.reset()
        TypedEventBus.main.queue = DispatchQueue.main
    }

    func testWithEventBus() {
        measure {
            let callExpectationLogin = XCTestExpectation(description: "subscribe called - login")
            let callExpectationLogout = XCTestExpectation(description: "subscribe called - logout")
            let callExpectationLogout2 = XCTestExpectation(description: "subscribe called - logout2")

            let eventBus = TypedEventBus.main
            eventBus.subscribeEvent(to: LoginEvent.self) { event in
                XCTAssertEqual(event.extraProperty, "extra")
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
            eventBus.post(LoginEvent(Person(name: "Joe")))
            wait(for: [callExpectationLogout, callExpectationLogin, callExpectationLogout2], timeout: timeout)
        }
    }

    func testSubscribePerformance() {
        let eventBus = TypedEventBus.main
        let subscriptionNbr = numberOfIterations
        measure {
            let loginExpectation = XCTestExpectation(description: "Login")
            func subscribe<O, Event: TypedEvent<O>>(to event: Event.Type) {
                eventBus.subscribe(to: Event.self) { _ in }.store(in: &cancellables)
            }
            for _ in 0..<subscriptionNbr {
                subscribe(to: LoginEvent.self)
                subscribe(to: LogoutEvent.self)
                subscribe(to: ApplicationStateChangedEvent.self)
                loginExpectation.fulfill()
            }
            wait(for: [loginExpectation], timeout: timeout)
            cancellables = []
        }
    }

    func testPostPerformance() {
        let eventBus = TypedEventBus.main
        let postingNbr = numberOfIterations
        measure {
            for _ in 0..<postingNbr {
                eventBus.post(LoginEvent(Person(name: "Jyx")))
                eventBus.post(ApplicationStateChangedEvent(.authenticated))
                eventBus.post(LogoutEvent(Person(name: "Jane")))
            }
        }
    }

    func testPerformance() {
        let eventBus = TypedEventBus.main
        let subscriptionNbr = numberOfIterations
        measure {
            var expectations = [XCTestExpectation]()
            func subscribe<O, Event: TypedEvent<O>>(to event: Event.Type, times: Int) {
                let expectation = XCTestExpectation()
                expectations.append(expectation)
                var currentIteration = 0
                for _ in 0..<times {
                    eventBus.subscribe(to: Event.self) { _ in
                        currentIteration += 1
                        if currentIteration == times {
                            expectation.fulfill()
                        }
                    }.store(in: &cancellables)
                }
            }
            subscribe(to: LoginEvent.self, times: subscriptionNbr)
            subscribe(to: LogoutEvent.self, times: subscriptionNbr)
            subscribe(to: ApplicationStateChangedEvent.self, times: subscriptionNbr)
            eventBus.post(LoginEvent(Person(name: "Jyx")))
            eventBus.post(ApplicationStateChangedEvent(.authenticated))
            eventBus.post(LogoutEvent(Person(name: "Jane")))
            wait(for: expectations, timeout: timeout)
        }
    }
}
