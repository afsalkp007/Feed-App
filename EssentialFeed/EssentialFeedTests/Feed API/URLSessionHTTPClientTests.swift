//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 01/06/2024.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient: HTTPClient {
  let session: URLSession
  
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  struct UnexpectedValuesRepresentation: Error {}
  
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    session.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(.failure(error))
      } else if let data = data, let response = response as? HTTPURLResponse {
        completion(.success(data, response))
      } else {
        completion(.failure(UnexpectedValuesRepresentation()))
      }
    }.resume()
  }
}

class URLSessionHTTPClientTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    
    URLProtocolStub.startInterceptingRequests()
  }
  
  override func tearDown() {
    super.tearDown()
    
    URLProtocolStub.stopInterceptingRequests()
  }
  
  func tes_getFromURL_performsGETRequestWithURL() {
    let url = anyURL()
    let exp = expectation(description: "Wait for request")
    
    URLProtocolStub.observeRequests { request in
      XCTAssertEqual(request.url, url)
      XCTAssertEqual(request.httpMethod, "GET")
      exp.fulfill()
    }
    
    makeSUT().get(from: url) { _ in }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_getFromURL_failsOnRequestError() {
    let requestError = anyNSError()
    
    let receivedError = resultError(for: nil, response: nil, error: requestError) as NSError?
    
    XCTAssertEqual(receivedError?.domain, requestError.domain)
    XCTAssertEqual(receivedError?.code, requestError.code)
  }
  
  func test_getFromURL_failsOnAllInvalidRepresentationCases() {
    XCTAssertNotNil(resultError(for: nil, response: nil, error: nil))
    XCTAssertNotNil(resultError(for: nil, response: nonHTTPURLResponse(), error: nil))
    XCTAssertNotNil(resultError(for: anyData(), response: nil, error: nil))
    XCTAssertNotNil(resultError(for: anyData(), response: nil, error: anyNSError()))
    XCTAssertNotNil(resultError(for: nil, response: nonHTTPURLResponse(), error: anyNSError()))
    XCTAssertNotNil(resultError(for: nil, response: anyHTTPURLResponse(), error: anyNSError()))
    XCTAssertNotNil(resultError(for: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
    XCTAssertNotNil(resultError(for: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
    XCTAssertNotNil(resultError(for: anyData(), response: nonHTTPURLResponse(), error: nil))
  }
  
  func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
    let data = anyData()
    let response = anyHTTPURLResponse()
    
    let receivedValues = resultValues(for: data, response: response, error: nil)
    
    XCTAssertEqual(receivedValues?.data, data)
    XCTAssertEqual(receivedValues?.response.url, response.url)
    XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
  }
  
  func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
    let response = anyHTTPURLResponse()
    
    let receivedValues = resultValues(for: nil, response: response, error: nil)
    
    let emptyData = Data()
    XCTAssertEqual(receivedValues?.data, emptyData)
    XCTAssertEqual(receivedValues?.response.url, response.url)
    XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
  }
  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
    let sut = URLSessionHTTPClient()
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func resultError(for data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
    let result = result(for: data, response: response, error: error)
    
    switch result {
    case let .failure(error):
      return error
    default:
      XCTFail("Expected failure, got \(result) instead.", file: file, line: line)
      return nil
    }
  }
  
  private func resultValues(for data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
    let result = result(for: data, response: response, error: error)
    
    switch result {
    case let .success(data, response):
      return (data, response)
    default:
      XCTFail("Expected success, got \(result) instead.", file: file, line: line)
      return nil
    }
  }
  
  private func result(for data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
    URLProtocolStub.stub(data: data, response: response, error: error)
    let sut = makeSUT(file: file, line: line)
    let exp = expectation(description: "Wait for completion")
    
    var receivedResult: HTTPClientResult!
    sut.get(from: anyURL()) { result in
      receivedResult = result
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
    return receivedResult
  }
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
  
  private func anyHTTPURLResponse() -> HTTPURLResponse {
    return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
  }
  
  private func nonHTTPURLResponse() -> URLResponse {
    return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
  }
  
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
  
  private func anyData() -> Data {
    return Data("any data".utf8)
  }
  
  private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?

    private struct Stub {
      let data: Data?
      let response: URLResponse?
      let error: Error?
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
      stub = Stub(data: data, response: response, error: error)
    }
    
    static func observeRequests(_ request: @escaping (URLRequest) -> Void) {
      requestObserver = request
    }
    
    static func startInterceptingRequests() {
      URLProtocol.registerClass(URLProtocolStub.self)
    }

    static func stopInterceptingRequests() {
      URLProtocol.unregisterClass(URLProtocolStub.self)
      stub = nil
      requestObserver = nil
    }
  
    override class func canInit(with request: URLRequest) -> Bool {
      requestObserver?(request)
      return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      return request
    }
    
    override func startLoading() {
      if let data = URLProtocolStub.stub?.data {
        client?.urlProtocol(self, didLoad: data)
      }

      if let response = URLProtocolStub.stub?.response {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      }

      if let error = URLProtocolStub.stub?.error {
        client?.urlProtocol(self, didFailWithError: error)
      }

      client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
  }
}
