//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Afsal on 19/06/2024.
//

import Foundation

public enum RetrieveCachedFeedResult {
  case empty
  case found([LocalFeedImage], Date)
  case failure(Error)
}

public protocol FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void
  typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void

  func deleteCachedFeed(_ completion: @escaping DeletionCompletion)
  func insert(_ feed: [LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion)
  func retrieve(completion: @escaping RetrievalCompletion)
}

