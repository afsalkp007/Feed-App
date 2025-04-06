//
//  FeedItemsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 27/05/2024.
//

import XCTest
import EssentialFeed

class FeedItemsMapperTests: XCTestCase {
  
  func test_map_throwsErrorOnNon200HTTPResponse() throws {
    let json = makeItemsJSON([])
    let samples = [199, 201, 300, 400, 500]
    
    try samples.forEach { code in
      XCTAssertThrowsError(
        try FeedItemsMapper.map(json, HTTPURLResponse(statusCode: code))
      )
    }
  }
  
  func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
    let invalidJSON = Data("invalid json".utf8)
    
    XCTAssertThrowsError(
      try FeedItemsMapper.map(invalidJSON, HTTPURLResponse(statusCode: 200))
    )
  }
  
  func test_map_deliversNoItemsOn200HTTPResponseWithEmptyList() throws {
    let emptyListJSON = makeItemsJSON([])
    
    let result = try FeedItemsMapper.map(emptyListJSON, HTTPURLResponse(statusCode: 200))
    
    XCTAssertEqual(result, [])
  }
  
  func test_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
    let item1 = makeItem(
      id: UUID(),
      imageURL: URL(string: "http://a-url.com")!)
    
    let item2 = makeItem(
      id: UUID(),
      description: "a description",
      location: "a location",
      imageURL: URL(string: "http://a-url.com")!)
    
    let json = makeItemsJSON([item1.json, item2.json])
    
    let result = try FeedItemsMapper.map(json, HTTPURLResponse(statusCode: 200))
    
    XCTAssertEqual(result, [item1.model, item2.model])
  }
  
  // MARK: - Helpers
  
  private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
    let model = FeedImage(
      id: id,
      description: description,
      location: location,
      url: imageURL)
    
    let json = [
      "id": model.id.uuidString,
      "description": model.description,
      "location": model.location,
      "image": model.url.absoluteString
    ].compactMapValues { $0 }
    
    return (model, json)
  }
}
