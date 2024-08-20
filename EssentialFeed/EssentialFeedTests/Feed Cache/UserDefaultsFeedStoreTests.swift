//
//  UserDefaultsFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 26/06/2024.
//

import XCTest
import EssentialFeed

class UserDefaultsFeedStoreTests: XCTestCase, FeedStoreSpecs {
  override func setUp() {
    super.setUp()
    
    deleteObject()
  }
  
  override func tearDown() {
    super.tearDown()
    
    deleteObject()
  }
    
  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = makeSUT()
    
    assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
  }
  
  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    
    assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
  }
  
  func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
    let sut = makeSUT()
    
    assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
  }
  
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    
    assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
  }
  
  func test_insert_deliversNoErrorOnEmptyCache() {
    let sut = makeSUT()
    
    assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
  }
  
  func test_insert_deliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()
    
    assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
  }
  
  func test_insert_overridesPreviouslyInsertedCacheValues() {
    let sut = makeSUT()
    
    assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
  }
  
  func test_delete_deliversNoErrorOnEmptyCache() {
    let sut = makeSUT()
    
    assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
  }
  
  func test_delete_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    
    assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
  }
  
  func test_delete_deliversNoErrorOnNonEmptyCache() {
    let sut = makeSUT()
    
    assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
  }
  
  func test_delete_emptiesPreviouslyInsertedCache() {
    let sut = makeSUT()
    
    assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
  }
  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
    let sut = UserDefaultsFeedStore()
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func deleteObject() {
    UserDefaults.standard.removeObject(forKey: "Cache")
  }
}
