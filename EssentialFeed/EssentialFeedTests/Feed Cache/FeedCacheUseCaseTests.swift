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
  var insertionCallCount = 0
  var insertions = [(itms: [FeedItem], timestamp: Date)]()
  
  var deletionCompletions = [(Error?) -> Void]()
  
  func deleteCachedFeed(_ completion: @escaping (Error?) -> Void) {
    deletionCallCount += 1
    deletionCompletions.append(completion)
  }
  
  func insert(_ items: [FeedItem], currentDate: Date) {
    insertionCallCount += 1
    insertions.append((items, currentDate))
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }
  
  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }
}

class LocalFeedLoader {
  let store: FeedStore
  let currentDate: () -> Date
  
  init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
  func save(_ items: [FeedItem]) {
    store.deleteCachedFeed { [unowned self] error in
      if error == nil {
        self.store.insert(items, currentDate: self.currentDate())
      }
    }
  }
}

class FeedCacheUseCaseTests: XCTestCase {
  
  func test_init_doesNotDeleteCache() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.deletionCallCount, 0)
  }
  
  func test_save_requestsDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem()]
    
    sut.save(items)
    
    XCTAssertEqual(store.deletionCallCount, 1)
  }
  
  func test_save_doesNotRequestsCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem()]
    let error = anyNSError()
    
    sut.save(items)
    store.completeDeletion(with: error)
    
    XCTAssertEqual(store.insertionCallCount, 0)
  }
  
  func test_save_requestsCacheInsertionOnSuccessfulDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem()]
    
    sut.save(items)
    store.completeDeletionSuccessfully()
    
    XCTAssertEqual(store.insertionCallCount, 1)
  }
  
  func test_save_requestsCacheInsertionWithTimestampOnSuccessfulDeletion() {
    let timestamp = Date()
    let (sut, store) = makeSUT(currentDate: { timestamp })
    let items = [uniqueItem()]
    
    sut.save(items)
    store.completeDeletionSuccessfully()
    
    XCTAssertEqual(store.insertions.count, 1)
  }
  
  // MARK: - Helpers
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(store, file: file, line: line)
    return (sut, store)
  }
  
  func uniqueItem() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
}
