//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 27/05/2024.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
  
  func test_init_doesNotRequestsDataFromURL() {
    let (_, client) = makeSUT()
    
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }
  
  func test_load_requestsDataFromURL() {
    let url = URL(string: "https://a-given-url.com")!
    let (sut, client) = makeSUT(url: url)
    
    sut.load { _ in }
    
    XCTAssertEqual(client.requestedURLs, [url])
  }
  
  func test_loadTwice_requestsDataFromURLTwice() {
    let url = URL(string: "https://a-given-url.com")!
    let (sut, client) = makeSUT(url: url)
    
    sut.load { _ in }
    sut.load { _ in }
    
    XCTAssertEqual(client.requestedURLs, [url, url])
  }
  
  func test_load_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()
    
    expect(sut, toExpect: .failure(.connectivity), when: {
      let clientError = NSError(domain: "Test", code: 0)
      client.complete(with: clientError)
    })
  }
  
  func test_load_deliversErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()
    
    let samples = [199, 201, 300, 400, 500]
    
    samples.enumerated().forEach { index, code in
      expect(sut, toExpect: .failure(.invalidData), when: {
        let json = makeItemsJSON([])
        client.complete(withStatusCode: code, data: json, at: index)
      })
    }
  }
  
  func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
    let (sut, client) = makeSUT()
    
    expect(sut, toExpect: .failure(.invalidData), when: {
      let invalidJSON = Data("invalid json".utf8)
      client.complete(withStatusCode: 200, data: invalidJSON)
    })
  }
  
  func test_load_deliversNoItemsOn200HTTPResponseWithEmptyList() {
    let (sut, client) = makeSUT()
    
    expect(sut, toExpect: .success([]), when: {
      let emptyListJSON = makeItemsJSON([])
      client.complete(withStatusCode: 200, data: emptyListJSON)
    })
  }
  
  func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
    let (sut, client) = makeSUT()
    
    let item1 = makeItem(
      id: UUID(),
      imageURL: URL(string: "http://a-url.com")!)
    
    let item2 = makeItem(
      id: UUID(),
      description: "a description",
      location: "a location",
      imageURL: URL(string: "http://a-url.com")!)
    
    let items: [FeedItem] = [item1.model, item2.model]
    
    expect(sut, toExpect: .success(items), when: {
      let json = makeItemsJSON([item1.json, item2.json])
      client.complete(withStatusCode: 200, data: json)
    })
  }
  
  // MAKR: - Helpers
  
  private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)
    return (sut, client)
  }
  
  private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
    let model = FeedItem(
      id: id,
      description: description,
      location: location,
      imageURL: imageURL)
    
    let json = [
      "id": model.id.uuidString,
      "description": model.description,
      "location": model.location,
      "image": model.imageURL.absoluteString
    ].compactMapValues { $0 }
    
    return (model, json)
  }
  
  private func makeItemsJSON(_ items: [[String : Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
  }
  
  private func expect(_ sut: RemoteFeedLoader, toExpect result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    var capturedResults = [RemoteFeedLoader.Result]()
    sut.load { capturedResults.append($0) }
    
    action()
    
    XCTAssertEqual(capturedResults, [result], file: file, line: line)
  }
  
  private class HTTPClientSpy: HTTPClient {
    private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    
    var requestedURLs: [URL] {
      return messages.map(\.url)
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
      messages.append((url, completion))
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
      messages[index].completion(.success(data, response))
    }
  }
}
