//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 09/07/2024.
//

import XCTest
import EssentialFeed

class CacheFeedImageDataUseCaseTests: XCTestCase {
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertTrue(store.receivedMessages.isEmpty)
  }
  
  func test_saveImageDataFromURL_requestsImageDataInsertion() {
    let (sut, store) = makeSUT()
    let url = anyURL()
    let data = anyData()
    
    try? sut.save(data, for: url)
    
    XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
  }
  
  func test_saveImageDataFromURL_failsOnInsertionError() {
    let (sut, store) = makeSUT()
    
    expect(sut, toCompleteWith: failed(), when: {
      let insertionError = anyNSError()
      store.completeInsertion(with: insertionError)
    })
  }

  func test_saveImageDataFromURL_SucceedsOnSuccessfulInsertion() {
    let (sut, store) = makeSUT()
    
    expect(sut, toCompleteWith: .success(()), when: {
      store.completeInsertionSuccessfully()
    })
  }

  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
    let store = FeedImageDataStoreSpy()
    let sut = LocalFeedImageDataLoader(store: store)
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(store, file: file, line: line)
    return (sut, store)
  }
  
  private func failed() -> Result<Void, Error> {
    .failure(LocalFeedImageDataLoader.SaveError.failed)
  }
  
  private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: Result<Void, Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    action()
    
    let receivedResult = Result { try sut.save(anyData(), for: anyURL()) }
    
    switch (receivedResult, expectedResult) {
    case (.success, .success):
      break
      
    case let (.failure(receivedError as LocalFeedImageDataLoader.SaveError), .failure(expectedError as LocalFeedImageDataLoader.SaveError)):
      XCTAssertEqual(receivedError, expectedError, file: file, line: line)
      
    default:
      XCTFail("Expected success, got \(receivedResult) instead", file: file, line: line)
    }
  }
}
