import XCTest
@testable import InvitationMiddleware

final class InvitationMiddlewareTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(InvitationMiddleware().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
