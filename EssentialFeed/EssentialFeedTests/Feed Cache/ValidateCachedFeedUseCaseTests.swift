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
    
    sut.validateCache()
    store.completeRetrieval(with: anyNSError())
    
    XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCacheFeed])
  }
  
  func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
    let (sut, store) = makeSUT()
    
    sut.validateCache()
    store.completeRetrievalWithEmptyCache()
    
    XCTAssertEqual(store.receivedMessage, [.retrieve])
  }
  
  func test_validateCache_doesNotDeleteCacheOnLessThanSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let currentDate = Date()
    let lessThanSevenDaysOldCache = currentDate.adding(days: -7).adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { currentDate })

    sut.validateCache()
    store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldCache)
    
    XCTAssertEqual(store.receivedMessage, [.retrieve])
  }

  func test_validateCache_deleteCacheOnSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let currentDate = Date()
    let sevenDaysOldCache = currentDate.adding(days: -7)
    let (sut, store) = makeSUT(currentDate: { currentDate })

    sut.validateCache()
    store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldCache)
    
    XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCacheFeed])
  }
  
  func test_validateCache_deleteCacheOnMoreThanSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let currentDate = Date()
    let moreThanSevenDaysOldCache = currentDate.adding(days: -7).adding(seconds: -1)
    let (sut, store) = makeSUT(currentDate: { currentDate })

    sut.validateCache()
    store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldCache)
    
    XCTAssertEqual(store.receivedMessage, [.retrieve, .deleteCacheFeed])
  }
  
  func test_validateCache_doesNotDeliverResultAfterSUTInstaneHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    
    sut?.validateCache()
    
    sut = nil
    store.completeRetrieval(with: anyNSError())
    
    XCTAssertEqual(store.receivedMessage, [.retrieve])
  }
  
  // MARK: - Helpers
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(store, file: file, line: line)
    return (sut, store)
  }
}
