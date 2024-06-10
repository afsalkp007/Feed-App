//
//  FeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 10/06/2024.
//

import XCTest
import EssentialFeed

class FeedStore {
  var insertions = [(itms: [FeedItem], timestamp: Date)]()
  
  typealias DeletionCompletion = (Error?) -> Void
  
  enum Message: Equatable {
    case deleteCache
    case insert(_ items: [FeedItem], _ timestamp: Date)
  }
  
  var deletionCompletions = [DeletionCompletion]()
  
  var receivedMessage = [Message]()
  
  func deleteCachedFeed(_ completion: @escaping DeletionCompletion) {
    receivedMessage.append(.deleteCache)
    deletionCompletions.append(completion)
  }
  
  func insert(_ items: [FeedItem], currentDate: Date) {
    receivedMessage.append(.insert(items, currentDate))
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
  
  func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
    store.deleteCachedFeed { [unowned self] error in
      completion(error)
      if error == nil {
        self.store.insert(items, currentDate: self.currentDate())
      }
    }
  }
}

class FeedCacheUseCaseTests: XCTestCase {
  
  func test_init_doesNotDeleteCache() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessage, [])
  }
  
  func test_save_requestsDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem()]
    
    sut.save(items) { _ in }
    
    XCTAssertEqual(store.receivedMessage, [.deleteCache])
  }
  
  func test_save_doesNotRequestsCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem()]
    let error = anyNSError()
    
    sut.save(items) { _ in }
    store.completeDeletion(with: error)
    
    XCTAssertEqual(store.receivedMessage, [.deleteCache])
  }
  
  func test_save_requestsCacheInsertionWithTimestampOnSuccessfulDeletion() {
    let timestamp = Date()
    let (sut, store) = makeSUT(currentDate: { timestamp })
    let items = [uniqueItem()]
    
    sut.save(items) { _ in }
    store.completeDeletionSuccessfully()
    
    XCTAssertEqual(store.receivedMessage, [.deleteCache, .insert(items, timestamp)])
  }
  
  func test_save_deliversErrorOnDeletionError() {
    let (sut, store) = makeSUT()
    let items = [uniqueItem()]
    let deletionError = anyNSError()
    
    let exp = expectation(description: "Wait for save completion")
    var receivedError: Error?
    sut.save(items) { error in
      receivedError = error
      exp.fulfill()
    }
    
    store.completeDeletion(with: deletionError)
    wait(for: [exp], timeout: 1.0)
    
    XCTAssertEqual(receivedError as NSError?, deletionError)
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
