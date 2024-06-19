//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Afsal on 19/06/2024.
//

import Foundation

public final class LocalFeedLoader {
  let store: FeedStore
  let currentDate: () -> Date
  
  public typealias SaveResult = Error?
  
  public init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
  public func save(_ items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
    store.deleteCachedFeed { [weak self] error in
      guard let self = self else { return }
      
      if let error = error {
        completion(error)
      } else {
        self.cache(items, with: completion)
      }
    }
  }
  
  private func cache(_ items: [FeedItem], with completion: @escaping (SaveResult) -> Void) {
    store.insert(items, currentDate: self.currentDate()) { [weak self] error in
      guard self != nil else { return }
      completion(error)
    }
  }
}
