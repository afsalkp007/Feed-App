//
//  LoadFeedFromCacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 23/06/2024.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheFeedUseCaseTests: XCTestCase {
  
  func test_init_doesNotDeleteCache() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessage, [])
  }
  
  func test_load_requestsCacheRetrieval() {
    let (sut, store) = makeSUT()
    
    sut.load { _ in }
    
    XCTAssertEqual(store.receivedMessage, [.retrieve])
  }
  
  func test_loadFailsOnRetrievalError() {
    let (sut, store) = makeSUT()
    let retrievalError = anyNSError()
 
    expect(sut, toExpectWith: .failure(retrievalError), when: {
      store.completeRetrieval(with: retrievalError)
    })
  }
  
  func test_deliversNoImagesOnEmptyCache() {
    let (sut, store) = makeSUT()
    
    expect(sut, toExpectWith: .success([]), when: {
      store.completeRetrievalWithEmptyCache()
    })
  }
  
  func test_load_deliversCachedImagesOnNonExpiredCache() {
    let feed = uniqueImageFeed()
    let currentDate = Date()
    let nonExpiredCache = currentDate.minusFeedCacheMaxAge().adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { currentDate })
    
    expect(sut, toExpectWith: .success(feed.models), when: {
      store.completeRetrieval(with: feed.local, timestamp: nonExpiredCache)
    })
  }
  
  func test_load_deliversNoImagesOnCacheExpiration() {
    let feed = uniqueImageFeed()
    let currentDate = Date()
    let expirationTimeStamp = currentDate.minusFeedCacheMaxAge()
    let (sut, store) = makeSUT(currentDate: { currentDate })
    
    expect(sut, toExpectWith: .success([]), when: {
      store.completeRetrieval(with: feed.local, timestamp: expirationTimeStamp)
    })
  }
  
  func test_load_deliversNoImagesOnExpiredCache() {
    let feed = uniqueImageFeed()
    let currentDate = Date()
    let expiredCache = currentDate.minusFeedCacheMaxAge().adding(seconds: -1)
    let (sut, store) = makeSUT(currentDate: { currentDate })
    
    expect(sut, toExpectWith: .success([]), when: {
      store.completeRetrieval(with: feed.local, timestamp: expiredCache)
    })
  }
  
  func test_load_hasNoSideEffectsOnRetrievalError() {
    let (sut, store) = makeSUT()
    
    sut.load { _ in }
    store.completeRetrieval(with: anyNSError())
    
    XCTAssertEqual(store.receivedMessage, [.retrieve])
  }
  
  func test_load_hasNoSideEffectsOnEmptyCache() {
    let (sut, store) = makeSUT()
    
    sut.load { _ in }
    store.completeRetrievalWithEmptyCache()
    
    XCTAssertEqual(store.receivedMessage, [.retrieve])
  }
  
  func test_load_hasNoSideEffectsOnNonExpiredCache() {
    let feed = uniqueImageFeed()
    let currentDate = Date()
    let nonExpiredCache = currentDate.minusFeedCacheMaxAge().adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { currentDate })

    sut.load { _ in }
    store.completeRetrieval(with: feed.local, timestamp: nonExpiredCache)
    
    XCTAssertEqual(store.receivedMessage, [.retrieve])
  }
  
  func test_load_hasNoSideEffectsOnCacheExpiration() {
    let feed = uniqueImageFeed()
    let currentDate = Date()
    let cacheExpirationTimeStamp = currentDate.minusFeedCacheMaxAge()
    let (sut, store) = makeSUT(currentDate: { currentDate })

    sut.load { _ in }
    store.completeRetrieval(with: feed.local, timestamp: cacheExpirationTimeStamp)
    
    XCTAssertEqual(store.receivedMessage, [.retrieve])
  }
  
  func test_load_hasNoSideEffectsOExpiredCache() {
    let feed = uniqueImageFeed()
    let currentDate = Date()
    let expiredCache = currentDate.minusFeedCacheMaxAge().adding(seconds: -1)
    let (sut, store) = makeSUT(currentDate: { currentDate })

    sut.load { _ in }
    store.completeRetrieval(with: feed.local, timestamp: expiredCache)
    
    XCTAssertEqual(store.receivedMessage, [.retrieve])
  }
  
  func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    
    var receivedResults = [LocalFeedLoader.LoadResult]()
    sut?.load { receivedResults.append($0) }
    
    sut = nil
    store.completeRetrievalWithEmptyCache()
    
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
    
  private func expect(_ sut: LocalFeedLoader, toExpectWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    
    sut.load { receivedResult in
      switch (receivedResult, expectedResult) {
      case let (.success(recievedImages), .success(expectedImages)):
        XCTAssertEqual(recievedImages, expectedImages, file: file, line: line)
        
      case let (.failure(receivedError), .failure(expectedError)):
        XCTAssertEqual(receivedError as NSError, expectedError as NSError?, file: file, line: line)
        
      default:
        XCTFail("Expected result \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
      }
      exp.fulfill()
    }
    
    action()
    wait(for: [exp], timeout: 1.0)
  }
}
