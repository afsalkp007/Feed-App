//
//  FeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 10/06/2024.
//

import XCTest

class FeedStore {
  var deletionCallCount = 0
}

class LocalFeedLoader {
  init(store: FeedStore) {
    
  }
}

class FeedCacheUseCaseTests: XCTestCase {
  
  func test_init_doesNotDeleteCache() {
    let store = FeedStore()
    _ = LocalFeedLoader(store: store)
    
    XCTAssertEqual(store.deletionCallCount, 0)
  }
}
