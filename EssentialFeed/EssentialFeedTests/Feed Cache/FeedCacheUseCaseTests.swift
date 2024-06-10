//
//  FeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 10/06/2024.
//

import XCTest
import EssentialFeed

class FeedStore {
  var deletionCallCount = 0
  
  func deleteItems() {
    deletionCallCount += 1
  }
}

class LocalFeedLoader {
  let store: FeedStore
  
  init(store: FeedStore) {
    self.store = store
  }
  
  func save(_ items: [FeedItem]) {
    store.deleteItems()
  }
}

class FeedCacheUseCaseTests: XCTestCase {
  
  func test_init_doesNotDeleteCache() {
    let store = FeedStore()
    _ = LocalFeedLoader(store: store)
    
    XCTAssertEqual(store.deletionCallCount, 0)
  }
  
  func test_save_deleteCache() {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)
    let items = [uniqueItem()]
    
    sut.save(items)
    
    XCTAssertEqual(store.deletionCallCount, 1)
  }
  
  // MARK: - Helpers
  
  func uniqueItem() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
}
