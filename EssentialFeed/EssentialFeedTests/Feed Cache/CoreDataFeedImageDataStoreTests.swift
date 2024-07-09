//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 09/07/2024.
//

import XCTest
import EssentialFeed

class CoreDataFeedImageDataStoreTests: XCTestCase {
  
  func test_retrieveImageData_DeliversNotFoundWhenEmpty() {
    let sut = makeSUT()
    
    expect(sut, toCompleteWith: notFound(), for: anyURL())
  }
  
  func test_retrieveImageData_DeliversNotFoundWhenStoredURLDoesNotMatch() {
    let sut = makeSUT()
    let url = URL(string: "http://a-url.com")!
    let nonMatchingURL = URL(string: "http://another-url.com")!
    
    insert(anyData(), for: url, into: sut)
    
    expect(sut, toCompleteWith: notFound(), for: nonMatchingURL)
  }
  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataFeedStore {
    let bundle = Bundle(for: CoreDataFeedStore.self)
    let storeURL = URL(filePath: "/dev/null")
    let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func notFound() -> FeedImageDataStore.RetrievalResult {
    return .success(.none)
  }
  
  private func localImage(for url: URL) -> LocalFeedImage {
    return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
  }
  
  private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "Wait for cache insertion")
    let image = localImage(for: url)
    sut.insert([image], timestamp: Date()) { result in
      switch result {
      case let .failure(error):
        XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
        
      case .success:
        sut.insert(data, for: url) { result in
          if case let Result.failure(error) = result {
            XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
          }
        }
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  private func expect(_ sut: CoreDataFeedStore, toCompleteWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL, file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    
    sut.retrieve(dataForURL: url) { receivedResult in
      switch (receivedResult, expectedResult) {
      case let (.success(receivedData), .success(expectedData)):
        XCTAssertEqual(receivedData, expectedData, file: file, line: line)
        
      case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        
      default:
        XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
}
