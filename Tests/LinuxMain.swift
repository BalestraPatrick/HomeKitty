// Generated using Sourcery 0.15.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest
@testable import AppTests

extension AboutControllerTests {
  static var allTests = [
    ("testAbout", testAbout),
  ]
}

extension AccessoryControllerTests {
  static var allTests = [
    ("testAccessories", testAccessories),
  ]
}

extension DonationControllerTests {
  static var allTests = [
    ("testDonationThanks", testDonationThanks),
  ]
}

extension FeedControllerTests {
  static var allTests = [
    ("testRSS", testRSS),
  ]
}

extension HomeControllerTests {
  static var allTests = [
    ("testHome", testHome),
  ]
}

extension ManufacturerControllerTests {
  static var allTests = [
    ("testManufacturers", testManufacturers),
  ]
}

extension ReportControllerTests {
  static var allTests = [
    ("testReport", testReport),
  ]
}


XCTMain([
  testCase(AboutControllerTests.allTests),
  testCase(AccessoryControllerTests.allTests),
  testCase(DonationControllerTests.allTests),
  testCase(FeedControllerTests.allTests),
  testCase(HomeControllerTests.allTests),
  testCase(ManufacturerControllerTests.allTests),
  testCase(ReportControllerTests.allTests),
])
