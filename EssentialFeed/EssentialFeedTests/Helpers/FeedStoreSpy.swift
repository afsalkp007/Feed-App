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

  var deletionCompletions = [DeletionCompletion]()
  var insertionCompletions = [InsertionCompletion]()
  var retrievalCompletions = [RetrievalCompletion]()
  
  func deleteCachedFeed(_ completion: @escaping DeletionCompletion) {
    receivedMessage.append(.deleteCacheFeed)
    deletionCompletions.append(completion)
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }
  
  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }
  
  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    receivedMessage.append(.insert(feed, timestamp))
    insertionCompletions.append(completion)
  }
  
  func completeInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](error)
  }
  
  func completeInsertionSuccessfully(at index: Int = 0) {
    insertionCompletions[index](nil)
  }
  
  func retrieve(completion: @escaping RetrievalCompletion) {
    retrievalCompletions.append(completion)
    receivedMessage.append(.retrieve)
  }
  
  func completeRetrieval(with error: Error, at index: Int = 0) {
    retrievalCompletions[index](.failure(error))
  }
  
  func completeRetrievalWithEmptyCache(at index: Int = 0) {
    retrievalCompletions[index](.empty)
  }
  
  func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
    retrievalCompletions[index](.found(feed, timestamp))
  }
}
