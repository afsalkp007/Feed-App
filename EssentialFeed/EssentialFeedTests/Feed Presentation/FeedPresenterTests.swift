//
//  FeedPresenter.swift
//  EssentialFeedTests
//
//  Created by Afsal on 06/07/2024.
//

import XCTest
import EssentialFeed

class FeedPresenterTests: XCTestCase {
  func test_title_isLocalized() {
    XCTAssertEqual(FeedPresenter.title, localized(key: "FEED_VIEW_TITLE"))
  }
    
  // MARK: - Helpers
  
  private func localized(key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
    let table = "Feed"
    let bundle = Bundle(for: FeedPresenter.self)
    let value = bundle.localizedString(forKey: key, value: nil, table: table)
    if value == key {
      XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
    }
    return value
  }
}
