//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 27/05/2024.
//

import XCTest

class HTTPClient {
  var requestedURL: URL?
}

class RemoteFeedLoader {
   
}

class RemoteFeedLoaderTests: XCTestCase {
  
  func test_init_doesNotRequestDataFromURL() {
    let client = HTTPClient()
    _ = RemoteFeedLoader()
    
    XCTAssertNil(client.requestedURL)
  }
}
