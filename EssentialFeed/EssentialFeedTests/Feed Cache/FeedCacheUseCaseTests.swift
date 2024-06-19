//
//  FeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 10/06/2024.
//

import XCTest
import EssentialFeed

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
      store.completeInsertion(with: insertionError)
    })
  }
  
  func test_save_succeedsOnSuccessfulCacheInsertion() {
    let (sut, store) = makeSUT()
    
    expect(sut, toCompleteWith: nil, when: {
      store.completeDeletionSuccessfully()
      store.completeInsertionSuccessfully()
    })
  }
  
  func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

    var receivedResults = [Error?]()
    sut?.save([uniqueItem()]) { receivedResults.append($0) }

    sut = nil
    store.completeDeletion(with: anyNSError())

    XCTAssertTrue(receivedResults.isEmpty)
  }
  
  func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

    var receivedResults = [Error?]()
    sut?.save([uniqueItem()]) { receivedResults.append($0) }

    store.completeDeletionSuccessfully()
    sut = nil
    store.completeInsertion(with: anyNSError())

    XCTAssertTrue(receivedResults.isEmpty)
  }
  
  // MARK: - Helpers
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(store, file: file, line: line)
    return (sut, store)
  }
  
  private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedError: NSError?, when action: () -> Void) {
    let exp = expectation(description: "Wait for save completion")
    
    sut.save([uniqueItem()]) { error in
      XCTAssertEqual(error as NSError?, expectedError)
      exp.fulfill()
    }
    
    action()
    wait(for: [exp], timeout: 1.0)
  }
  
  func uniqueItem() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
  
  private class FeedStoreSpy: FeedStore {
    enum Message: Equatable {
      case deleteCache
      case insert(_ items: [FeedItem], _ timestamp: Date)
    }

    var receivedMessage = [Message]()

    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [InsertionCompletion]()
    
    func deleteCachedFeed(_ completion: @escaping DeletionCompletion) {
      receivedMessage.append(.deleteCache)
      deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
      deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
      deletionCompletions[index](nil)
    }
    
    func insert(_ items: [FeedItem], currentDate: Date, completion: @escaping InsertionCompletion) {
      receivedMessage.append(.insert(items, currentDate))
      insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
      insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
      insertionCompletions[index](nil)
    }
  }
}
