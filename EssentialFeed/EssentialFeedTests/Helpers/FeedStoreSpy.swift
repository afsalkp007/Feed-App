//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Afsal on 23/06/2024.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
  enum Message: Equatable {
    case deleteCacheFeed
    case insert(_ feed: [LocalFeedImage], _ timestamp: Date)
    case retrieve
  }

  var receivedMessage = [Message]()

  var deletionResult: Result<Void, Error>?
  var insertionResult: Result<Void, Error>?
  var retrievalResult: Result<CachedFeed?, Error>?
  
  func deleteCachedFeed() throws {
    receivedMessage.append(.deleteCacheFeed)
    try deletionResult?.get()
  }
  
  func completeDeletion(with error: Error) {
    deletionResult = .failure(error)
  }
  
  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionResult = .success(())
  }
  
  func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
    receivedMessage.append(.insert(feed, timestamp))
    try insertionResult?.get()
  }
  
  func completeInsertion(with error: Error, at index: Int = 0) {
    insertionResult = .failure(error)
  }
  
  func completeInsertionSuccessfully() {
    insertionResult = .success(())
  }
  
  func retrieve() throws -> CachedFeed? {
    receivedMessage.append(.retrieve)
    return try retrievalResult?.get()
  }
  
  func completeRetrieval(with error: Error, at index: Int = 0) {
    retrievalResult = .failure(error)
  }
  
  func completeRetrievalWithEmptyCache(at index: Int = 0) {
    retrievalResult = .success(.none)
  }
  
  func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
    retrievalResult = .success(CachedFeed(feed: feed, timestamp: timestamp))
  }
}
