//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Afsal on 24/06/2024.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
  func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieve: .empty, file: file, line: line)
  }
  
  func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieveTwice: .empty, file: file, line: line)
  }
  
  func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    insert((feed, timestamp), to: sut)
    
    expect(sut, toRetrieve: .found(feed, timestamp), file: file, line: line)
  }
  
  func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    insert((feed, timestamp), to: sut)

    expect(sut, toRetrieveTwice: .found(feed, timestamp), file: file, line: line)
  }
  
  func assertThatInsertDeliversNoErrorNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let latestFeed = uniqueImageFeed().local
    let latestTimestamp = Date()
    let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
    
    XCTAssertNil(latestInsertionError, "Expected to override cache successfully", file: file, line: line)
  }
  
  func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
    XCTAssertNil(firstInsertionError, "Expected to insert cache successfully", file: file, line: line)
  }
  
  func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let latestFeed = uniqueImageFeed().local
    let latestTimestamp = Date()
    insert((latestFeed, latestTimestamp), to: sut)

    expect(sut, toRetrieve: .found(latestFeed, latestTimestamp), file: file, line: line)
  }
  
  func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
  }
  
  func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    deleteCache(from: sut)
    
    expect(sut, toRetrieve: .empty, file: file, line: line)
  }
  
  func asssertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
  }
  
  func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)
    
    deleteCache(from: sut)
    
    expect(sut, toRetrieve: .empty, file: file, line: line)
  }
  
  func assertThatStoreSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
    var completeOperationsInOrder = [XCTestExpectation]()
    
    let op1 = expectation(description: "Operation 1")
    sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
      completeOperationsInOrder.append(op1)
      op1.fulfill()
    }
    
    let op2 = expectation(description: "Operation 2")
    sut.deleteCachedFeed { _ in
      completeOperationsInOrder.append(op2)
      op2.fulfill()
    }
    
    let op3 = expectation(description: "Operation 3")
    sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
      completeOperationsInOrder.append(op3)
      op3.fulfill()
    }

    waitForExpectations(timeout: 5.0)
    
    XCTAssertEqual(completeOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
  }
  
  @discardableResult
  func deleteCache(from sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for deletion completion")
    var deletionError: Error?
    sut.deleteCachedFeed { receivedDeletionError in
      deletionError = receivedDeletionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return deletionError
  }
  
  @discardableResult
  func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for retrieval completion")
    var insertionError: Error?
    sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
      insertionError = receivedInsertionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return insertionError
  }
  
  func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
  
  func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "Wait for retrieval completion")
    
    sut.retrieve { retrievedResult in
      switch (retrievedResult, expectedResult) {
      case (.empty, .empty),
        (.failure, .failure):
        break
        
      case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
        XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
        XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)
        
      default:
        XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead.", file: file, line: line)
      }
      
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
  }
}
