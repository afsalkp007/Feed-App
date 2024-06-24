//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Afsal on 24/06/2024.
//

import XCTest
import EssentialFeed

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
  func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
  }
  
  func assertThatRetrieveHasNoSideEffectsOnRetrievalError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
  }
}
