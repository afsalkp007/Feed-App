//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Afsal on 26/06/2024.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {
  override func setUp() {
    super.setUp()

    setupEmptyStoreState()
  }

  override func tearDown() {
    super.tearDown()

    undoStoreSideEffects()
  }

  func test_load_deliversNoItemsOnEmptyCache() {
    let sut = makeSUT()
    
    expect(sut, toLoad: [])
  }
  
  func test_load_deliversItemsSavedOnASeparateInstance() {
    let sutToPerformSave = makeSUT()
    let sutToPerformLoad = makeSUT()
    let feed = uniqueImageFeed().models

    save(feed, to: sutToPerformSave)
    
    expect(sutToPerformLoad, toLoad: feed)
  }
  
  func test_save_overridesItemsSavedOnASeparateInstance() {
    let sutToPerformFirstSave = makeSUT()
    let sutToPerformLastSave = makeSUT()
    let sutToPerformLoad = makeSUT()
    let firstFeed = uniqueImageFeed().models
    let latestFeed = uniqueImageFeed().models

    save(firstFeed, to: sutToPerformFirstSave)
    save(latestFeed, to: sutToPerformLastSave)
    
    expect(sutToPerformLoad, toLoad: latestFeed)
  }

  // MARK: Helpers

  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
    let storeBundle = Bundle(for: CoreDataFeedStore.self)
    let storeURL = testSpecificStoreURL()
    let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
    let sut = LocalFeedLoader(store: store, currentDate: Date.init)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func save(_ feed: [FeedImage], to sut: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for save completion")
    sut.save(feed) { result in
      if case let Result.failure(saveError) = result {
        XCTAssertNil(saveError, "Expected to save feed successfully", file: file, line: line)
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    sut.load { result in
      switch result {
      case let .success(imageFeed):
        XCTAssertEqual(imageFeed, expectedFeed, "Expected empty feed")

      case let .failure(error):
        XCTFail("Expected successful feed result, got \(error) instead")
      }

      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  private func setupEmptyStoreState() {
    deleteStoreArtifacts()
  }

  private func undoStoreSideEffects() {
    deleteStoreArtifacts()
  }

  private func deleteStoreArtifacts() {
    try? FileManager.default.removeItem(at: testSpecificStoreURL())
  }

  private func testSpecificStoreURL() -> URL {
    return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
  }

  private func cachesDirectory() -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
  }
  
}
