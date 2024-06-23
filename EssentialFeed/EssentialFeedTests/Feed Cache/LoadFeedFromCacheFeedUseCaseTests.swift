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
  
  func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let currentDate = Date()
    let lessThanSevenDaysOldCache = currentDate.adding(days: -7).adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { currentDate })
    
    expect(sut, toExpectWith: .success(feed.models), when: {
      store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldCache)
    })
  }
  
  func test_load_deliversNoImagesOnSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let currentDate = Date()
    let sevenDaysOldCache = currentDate.adding(days: -7)
    let (sut, store) = makeSUT(currentDate: { currentDate })
    
    expect(sut, toExpectWith: .success([]), when: {
      store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldCache)
    })
  }
  
  func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let currentDate = Date()
    let moreThanSevenDaysOldCache = currentDate.adding(days: -7).adding(seconds: -1)
    let (sut, store) = makeSUT(currentDate: { currentDate })
    
    expect(sut, toExpectWith: .success([]), when: {
      store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldCache)
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
  
  func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
  }
  
  func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage()]
    let local = models.map(\.local)
    return (models, local)
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

private extension Date {
  func adding(days: Int) -> Date {
    let calendar = Calendar(identifier: .gregorian)
    return calendar.date(byAdding: .day, value: days, to: self)!
  }
  
  func adding(seconds: TimeInterval) -> Date {
    return self + seconds
  }
}

