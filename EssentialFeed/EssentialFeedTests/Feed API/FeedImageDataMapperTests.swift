//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 08/07/2024.
//

import XCTest
import EssentialFeed

class FeedImageDataMapperTests: XCTestCase {
  
  func test_map_throwsErrorOnNon200HTTPResponse() throws {
    let data = anyData()
    let samples = [199, 201, 300, 400, 500]
    
    try samples.forEach { code in
      XCTAssertThrowsError(
        try FeedImageDataMapper.map(data, response: HTTPURLResponse(statusCode: code))
      )
    }
  }
  
  func test_map_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
    let emptyData = Data()
    
    XCTAssertThrowsError(
      try FeedImageDataMapper.map(emptyData, response: HTTPURLResponse(statusCode: 200))
    )
  }
  
  func test_map_deliversReceivedNonEmptyDataOn200HTTPResponse() throws {
    let data = anyData()
    
    let result = try FeedImageDataMapper.map(data, response: HTTPURLResponse(statusCode: 200))
    
    XCTAssertEqual(result, data)
  }
}
