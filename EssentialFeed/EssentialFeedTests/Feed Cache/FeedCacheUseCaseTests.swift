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
    
    sut.save(uniqueImageFeed().models) { _ in }
    
    XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed])
  }
  
  func test_save_doesNotRequestsCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let error = anyNSError()
    
    sut.save(uniqueImageFeed().models) { _ in }
    store.completeDeletion(with: error)
    
    XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed])
  }
  
  func test_save_requestsCacheInsertionWithTimestampOnSuccessfulDeletion() {
    let timestamp = Date()
    let (sut, store) = makeSUT(currentDate: { timestamp })
    let feed = uniqueImageFeed()
    
    sut.save(feed.models) { _ in }
    store.completeDeletionSuccessfully()
    
    XCTAssertEqual(store.receivedMessage, [.deleteCacheFeed, .insert(feed.local, timestamp)])
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

    var receivedResults = [LocalFeedLoader.SaveResult]()
    sut?.save(uniqueImageFeed().models) { receivedResults.append($0) }

    sut = nil
    store.completeDeletion(with: anyNSError())

    XCTAssertTrue(receivedResults.isEmpty)
  }
  
  func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

    var receivedResults = [LocalFeedLoader.SaveResult]()
    sut?.save(uniqueImageFeed().models) { receivedResults.append($0) }

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
  
  private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "Wait for save completion")
    
    var receivedError: Error?
    sut.save(uniqueImageFeed().models) { result in
      if case let Result.failure(error) = result { receivedError = error }
      exp.fulfill()
    }
    
    action()
    wait(for: [exp], timeout: 1.0)
    
    XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
  }
}
