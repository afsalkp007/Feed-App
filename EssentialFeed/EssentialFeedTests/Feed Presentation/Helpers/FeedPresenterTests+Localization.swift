//
//  FeedPresenterTests+Localization.swift
//  EssentialFeedTests
//
//  Created by Afsal on 06/07/2024.
//

import XCTest
import EssentialFeed

extension FeedPresenterTests {
  func localized(key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
    let table = "Feed"
    let bundle = Bundle(for: FeedPresenter.self)
    let value = bundle.localizedString(forKey: key, value: nil, table: table)
    if value == key {
      XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
    }
    return value
  }
}
