//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 08/07/2024.
//

import XCTest
import EssentialFeed

class LoadFeedImageDataFromRemoteUseCaseTests: XCTestCase {
  
  func test_init_doesNotPerformAnyURLRequest() {
    let (_, client) = makeSUT()
    
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }
  
  func test_loadImageData_requestsDataFromURL() {
    let (sut, client) = makeSUT()
    let url = anyURL()
    
    _ = sut.loadImageData(from: url) { _ in }
    
    XCTAssertEqual(client.requestedURLs, [url])
  }
  
  func test_loadImageDataTwice_requestsDataFromURLTwice() {
    let (sut, client) = makeSUT()
    let url = anyURL()
    
    _ = sut.loadImageData(from: url) { _ in }
    _ = sut.loadImageData(from: url) { _ in }
    
    XCTAssertEqual(client.requestedURLs, [url, url])
  }
  
  func test_loadImageData_deliversConnectivityErrorOnClientError() {
    let (sut, client) = makeSUT()
    let clientError = anyNSError()
    
    expect(sut, toCompleteWith: failure(.connectivity), when: {
      client.complete(with: clientError)
    })
  }
  
  func test_loadImageData_deliversInvalidDataErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()
    let data = anyData()
    let samples = [199, 201, 300, 400, 500]
    
    samples.enumerated().forEach { index, code in
      expect(sut, toCompleteWith: failure(.invalidData), when: {
        client.complete(withStatusCode: code, data: data, at: index)
      })
    }
  }
  
  func test_loadImageData_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
    let (sut, client) = makeSUT()
    
    expect(sut, toCompleteWith: failure(.invalidData), when: {
      let emptyData = Data()
      client.complete(withStatusCode: 200, data: emptyData)
    })
  }
  
  func test_loadImageData_deliversNonEmptyDataOn200HTTPResponse() {
    let (sut, client) = makeSUT()
    let data = anyData()
    
    expect(sut, toCompleteWith: .success(data), when: {
      client.complete(withStatusCode: 200, data: data)
    })
  }
  
  func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
    let (sut, client) = makeSUT()
    let url = anyURL()
    
    let task = sut.loadImageData(from: url) { _ in }
    XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")
    
    task.cancel()
    XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is canclled")
  }
  
  func test_loadImageData_doesNotDeliverResultsAfterCancellingTask() {
    let (sut, client) = makeSUT()
    let nonEmptyData = Data("non-empty data".utf8)

    var received = [FeedImageDataLoader.Result]()
    let task = sut.loadImageData(from: anyURL()) { received.append($0) }
    task.cancel()

    client.complete(withStatusCode: 404, data: anyData())
    client.complete(withStatusCode: 200, data: nonEmptyData)
    client.complete(with: anyNSError())

    XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
  }
  
  func test_loadImageData_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
    let client = HTTPClientSpy()
    var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
    
    var capturedResults = [FeedImageDataLoader.Result]()
    _ = sut?.loadImageData(from: anyURL()) { capturedResults.append($0) }
    
    sut = nil
    client.complete(withStatusCode: 200, data: anyData())
    
    XCTAssertTrue(capturedResults.isEmpty)
  }
  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedImageDataLoader(client: client)
    trackForMemoryLeaks(client, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, client)
  }
  
  private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
    return .failure(error)
  }
  
  private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    let url = URL(string: "https://a-given-url.com")!
    
    let exp = expectation(description: "Wait for load completion")
    
    _ = sut.loadImageData(from: url) { receivedResult in
      switch (receivedResult, expectedResult) {
      case let (.success(receivedData), .success(expectedData)):
        XCTAssertEqual(receivedData, expectedData, file: file, line: line)
        
      case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        
      default:
        XCTFail("Expected \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
      }
      
      exp.fulfill()
    }
    
    action()
    
    wait(for: [exp], timeout: 1.0)
  }
}
