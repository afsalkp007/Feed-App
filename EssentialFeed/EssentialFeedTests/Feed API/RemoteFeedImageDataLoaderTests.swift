//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 08/07/2024.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
  private let client: HTTPClient
    
  init(client: HTTPClient) {
    self.client = client
  }
  
  public enum Error: Swift.Error {
    case invalidData
  }
  
  public struct HTTPTaskWrapper: FeedImageDataLoaderTask {
    let wrapped: HTTPClientTask
    
    public func cancel() {
      wrapped.cancel()
    }
  }
  
  @discardableResult
  func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
    HTTPTaskWrapper(wrapped: client.get(from: url) { [weak self] result in
      guard self != nil else { return }
      
      switch result {
      case let .success((data, response)):
        if response.statusCode == 200, !data.isEmpty {
          completion(.success(data))
        } else {
          completion(.failure(Error.invalidData))
        }
        
      case let .failure(error):
        completion(.failure(error))
      }
    })
  }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
  
  func test_init_doesNotPerformAnyURLRequest() {
    let (_, client) = makeSUT()
    
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }
  
  func test_loadImageData_requestsDataFromURL() {
    let (sut, client) = makeSUT()
    let url = anyURL()
    
    sut.loadImageData(from: url) { _ in }
    
    XCTAssertEqual(client.requestedURLs, [url])
  }
  
  func test_loadImageDataTwice_requestsDataFromURLTwice() {
    let (sut, client) = makeSUT()
    let url = anyURL()
    
    sut.loadImageData(from: url) { _ in }
    sut.loadImageData(from: url) { _ in }
    
    XCTAssertEqual(client.requestedURLs, [url, url])
  }
  
  func test_loadImageData_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()
    let clientError = NSError(domain: "a client error", code: 0)
    
    expect(sut, toCompleteWith: .failure(clientError), when: {
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
  
  func test_loadImageData_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
    let client = HTTPClientSpy()
    var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
    
    var capturedResults = [FeedImageDataLoader.Result]()
    sut?.loadImageData(from: anyURL()) { capturedResults.append($0) }
    
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
    
    sut.loadImageData(from: url) { receivedResult in
      switch (receivedResult, expectedResult) {
      case let (.success(receivedData), .success(expectedData)):
        XCTAssertEqual(receivedData, expectedData, file: file, line: line)
        
      case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        
      case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        
      default:
        XCTFail("Expected \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
      }
      
      exp.fulfill()
    }
    
    action()
    
    wait(for: [exp], timeout: 1.0)
  }
  
  private class HTTPClientSpy: HTTPClient {
    private struct Task: HTTPClientTask {
      func cancel() {}
    }
    
    var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    private(set) var cancelledURLs = [URL]()
    
    var requestedURLs: [URL] {
      return messages.map(\.url)
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
      messages.append((url, completion))
      return Task()
    }
    
    func complete(with error: Error, at index: Int = 0) {
      messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
      let response = HTTPURLResponse(
        url: requestedURLs[index],
        statusCode: code,
        httpVersion: nil,
        headerFields: nil)!
      messages[index].completion(.success((data, response)))
    }
  }
}
