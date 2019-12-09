import XCTest
@testable import CrookedText

final class CrookedTextTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CrookedText().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
