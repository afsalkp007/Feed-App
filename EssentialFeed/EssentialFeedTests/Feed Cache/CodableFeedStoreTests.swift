//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 24/06/2024.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
  private struct Cache: Codable {
    let feed: [CodableFeedImage]
    let timestamp: Date
    
    var local: [LocalFeedImage] {
      feed.map(\.local)
    }
  }
  
  private struct CodableFeedImage: Codable {
    private let id: UUID
    private let description: String?
    private let location: String?
    private let url: URL
    
    init(_ image: LocalFeedImage) {
      self.id = image.id
      self.description = image.description
      self.location = image.location
      self.url = image.url
    }
    
    var local: LocalFeedImage {
      return LocalFeedImage(id: id, description: description, location: location, url: url)
    }
  }

  
  private let storeURL: URL
  
  init(storeURL: URL) {
    self.storeURL = storeURL
  }
  
  func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
    guard let data = try? Data(contentsOf: storeURL) else {
      return completion(.empty)
    }
    
    let decoder = JSONDecoder()
    let cache = try! decoder.decode(Cache.self, from: data)
    completion(.found(cache.local, cache.timestamp))
  }
  
  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
    let encoder = JSONEncoder()
    let encoded = try! encoder.encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp))
    try! encoded.write(to: storeURL)
    completion(nil)
  }
}

class CodableFeedStoreTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    
    setupEmtpyStoreState()
  }
  
  override func tearDown() {
    super.tearDown()
    
    undoStoreSideEffects()
  }
  
  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = makeSUT()
    
    let exp = expectation(description: "Wait for retrieval completion")
    sut.retrieve { result in
      switch result {
      case .empty:
        break
        
      default:
        XCTFail("Expected empty, got \(result) instead.")
      }
      
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    
    let exp = expectation(description: "Wait for retrieval completion")
    sut.retrieve { firstResult in
      sut.retrieve { secondResult in
        switch (firstResult, secondResult) {
        case (.empty, .empty):
          break
          
        default:
          XCTFail("Expected empty, got \(firstResult) and \(secondResult) instead.")
        }
        
        exp.fulfill()
      }
    }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_retrieveAfterInserting_deliversInsertedValues() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    let exp = expectation(description: "Wait for retrieval completion")
    sut.insert(feed, timestamp: timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
      
      sut.retrieve { retrievedResult in
        switch retrievedResult {
        case let .found(retrievedFeed, retrievedTimestamp):
          XCTAssertEqual(retrievedFeed, feed)
          XCTAssertEqual(retrievedTimestamp, timestamp)
          
        default:
          XCTFail("Expected empty, got \(retrievedResult) instead.")
        }
        
        exp.fulfill()
      }
    }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
    let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func testSpecificStoreURL() -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(type(of: self)).store")
  }
  
  private func setupEmtpyStoreState() {
    deleteStoreArtifacts()
  }
  
  private func undoStoreSideEffects() {
    deleteStoreArtifacts()
  }
  
  private func deleteStoreArtifacts() {
    try? FileManager.default.removeItem(at: testSpecificStoreURL())
  }
}
