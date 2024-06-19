//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Afsal on 19/06/2024.
//

import Foundation

public protocol FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void

  func deleteCachedFeed(_ completion: @escaping DeletionCompletion)
  func insert(_ items: [FeedItem], currentDate: Date, completion: @escaping InsertionCompletion)
}

public class LocalFeedLoader {
  let store: FeedStore
  let currentDate: () -> Date
  
  public init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
  public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
    store.deleteCachedFeed { [weak self] error in
      guard let self = self else { return }
      
      if let error = error {
        completion(error)
      } else {
        self.cache(items, with: completion)
      }
    }
  }
  
  private func cache(_ items: [FeedItem], with completion: @escaping (Error?) -> Void) {
    store.insert(items, currentDate: self.currentDate()) { [weak self] error in
      guard self != nil else { return }
      completion(error)
    }
  }
}
