//
//  ValidateCachedFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 23/06/2024.
//

import XCTest
import EssentialFeed

class ValidateCachedFeedUseCaseTests: XCTestCase {
  
  func test_init_doesNotDeleteCache() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessage, [])
  }
  
  func test_validateCache_deleteCacheOnRetrievalError() {
    let (sut, store) = makeSUT()
    store.completeRetrieval(with: anyNSError())
    
    try? sut.validateCache()
    
    XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCacheFeed])
  }
  
  func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
    let (sut, store) = makeSUT()
    store.completeRetrievalWithEmptyCache()
    
    try? sut.validateCache()
    
    XCTAssertEqual(store.receivedMessage, [.retrieve])
  }
  
  func test_validateCache_doesNotDeleteCacheNonExpiredCache() {
    let feed = uniqueImageFeed()
    let currentDate = Date()
    let nonExpiredCache = currentDate.minusFeedCacheMaxAge().adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { currentDate })
    store.completeRetrieval(with: feed.local, timestamp: nonExpiredCache)

    try? sut.validateCache()
    
    XCTAssertEqual(store.receivedMessage, [.retrieve])
  }

  func test_validateCache_deleteCacheOnCacheExpiration() {
    let feed = uniqueImageFeed()
    let currentDate = Date()
    let cacheExpirationTimestamp = currentDate.minusFeedCacheMaxAge()
    let (sut, store) = makeSUT(currentDate: { currentDate })
    store.completeRetrieval(with: feed.local, timestamp: cacheExpirationTimestamp)

    try? sut.validateCache()
    
    XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCacheFeed])
  }
  
  func test_validateCache_deleteCacheOnExpiredCache() {
    let feed = uniqueImageFeed()
    let currentDate = Date()
    let expiredCache = currentDate.minusFeedCacheMaxAge().adding(seconds: -1)
    let (sut, store) = makeSUT(currentDate: { currentDate })
    store.completeRetrieval(with: feed.local, timestamp: expiredCache)

    try? sut.validateCache()
    
    XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCacheFeed])
  }
  
  func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
    let (sut, store) = makeSUT()
    let deletionError = anyNSError()

    expect(sut, toCompleteWith: .failure(deletionError), when: {
      store.completeRetrieval(with: anyNSError())
      store.completeDeletion(with: deletionError)
    })
  }

  func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
    let (sut, store) = makeSUT()

    expect(sut, toCompleteWith: .success(()), when: {
      store.completeRetrieval(with: anyNSError())
      store.completeDeletionSuccessfully()
    })
  }
  
  func test_validateCache_succeedsOnEmptyCache() {
    let (sut, store) = makeSUT()

    expect(sut, toCompleteWith: .success(()), when: {
      store.completeRetrievalWithEmptyCache()
    })
  }
  
  func test_validateCache_succeedsOnNonExpiredCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

    expect(sut, toCompleteWith: .success(()), when: {
      store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
    })
  }
  
  func test_validateCache_failsOnDeletionErrorOfExpiredCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    let deletionError = anyNSError()

    expect(sut, toCompleteWith: .failure(deletionError), when: {
      store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
      store.completeDeletion(with: deletionError)
    })
  }

  func test_validateCache_succeedsOnSuccessfulDeletionOfExpiredCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

    expect(sut, toCompleteWith: .success(()), when: {
      store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
      store.completeDeletionSuccessfully()
    })
  }
  
  // MARK: - Helpers
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(store, file: file, line: line)
    return (sut, store)
  }
  
  private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: Result<Void, Error>, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    action()
    
    let receivedResult = Result { try sut.validateCache() }
    
    switch (receivedResult, expectedResult) {
    case (.success, .success):
      break
      
    case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
      XCTAssertEqual(receivedError, expectedError, file: file, line: line)
      
    default:
      XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
    }
  }
}
