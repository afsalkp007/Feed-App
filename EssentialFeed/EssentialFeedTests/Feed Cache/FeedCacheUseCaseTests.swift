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
  typealias InsertionCompletion = (Error?) -> Void
    
  var deletionCompletions = [DeletionCompletion]()
  var insertionCompletions = [InsertionCompletion]()
  
  enum Message: Equatable {
    case deleteCache
    case insert(_ items: [FeedItem], _ timestamp: Date)
  }

  var receivedMessage = [Message]()
  
  func deleteCachedFeed(_ completion: @escaping DeletionCompletion) {
    receivedMessage.append(.deleteCache)
    deletionCompletions.append(completion)
  }
  
  func insert(_ items: [FeedItem], currentDate: Date, completion: @escaping InsertionCompletion) {
    receivedMessage.append(.insert(items, currentDate))
    insertions.append((items, currentDate))
    insertionCompletions.append(completion)
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }
  
  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }
  
  func compleInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](error)
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
      if error == nil {
        self.store.insert(items, currentDate: self.currentDate(), completion: completion)
      } else {
        completion(error)
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
    let deletionError = anyNSError()
    
    expect(sut, toCompleteWith: deletionError, when: {
      store.completeDeletion(with: deletionError)
    })
  }
  
  func test_save_deliversErrorOnInsertionError() {
    let (sut, store) = makeSUT()
    let insertionError = anyNSError()
    
    expect(sut, toCompleteWith: insertionError, when: {
      store.completeDeletionSuccessfully()
      store.compleInsertion(with: insertionError)
    })
  }
  
  // MARK: - Helpers
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(store, file: file, line: line)
    return (sut, store)
  }
  
  private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedError: NSError, when action: () -> Void) {
    let exp = expectation(description: "Wait for save completion")
    var receivedError: Error?
    sut.save([uniqueItem()]) { error in
      receivedError = error
      exp.fulfill()
    }
    
    action()
    wait(for: [exp], timeout: 1.0)
    
    XCTAssertEqual(receivedError as NSError?, expectedError)

  }
  
  func uniqueItem() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
}
