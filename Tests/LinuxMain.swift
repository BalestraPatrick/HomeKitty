#if os(Linux)

import XCTest
@testable import AppTests

XCTMain([
    testCase(AboutControllerTests.allTests),
    testCase(DonationControllerTests.allTests),
    testCase(ExploreControllerTests.allTests),
    testCase(ManufacturerControllerTests.allTests),
    testCase(HomeControllerTests.allTests),
    testCase(ReportControllerTests.allTests),
    testCase(FeedControllerTests.allTests),
    testCase(AccessoryControllerTests.allTests),
])

#endif
