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
    
  public init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
}
 
extension LocalFeedLoader {
  public typealias SaveResult = Swift.Result<Void, Error>

  public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
    store.deleteCachedFeed { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case .success:
        self.cache(feed, with: completion)
        
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }
  
  private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
    store.insert(feed.toLocal(), timestamp: self.currentDate()) { [weak self] result in
      guard self != nil else { return }
      
      completion(result)
    }
  }
}

extension LocalFeedLoader: FeedLoader {
  public typealias LoadResult = FeedLoader.Result

  public func load(completion: @escaping (LoadResult) -> Void) {
    store.retrieve { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case let .failure(error):
        completion(.failure(error))
        
      case let .success(cache) where FeedCachePolicy.validate(cache?.timestamp ?? Date(), against: self.currentDate()):
        completion(.success(cache?.feed.toModels() ?? []))
        
      case .success:
        completion(.success([]))
      }
    }
  }
}

extension LocalFeedLoader {
  public func validateCache() {
    store.retrieve { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case .failure:
        self.store.deleteCachedFeed { _ in }
        
      case let .success(cache) where !FeedCachePolicy.validate(cache?.timestamp ?? Date(), against: self.currentDate()):
        self.store.deleteCachedFeed { _ in }
        
      case .success: break
      }
    }
  }
}

private extension Array where Element == FeedImage {
  func toLocal() -> [LocalFeedImage] {
    return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
  }
}

private extension Array where Element == LocalFeedImage {
  func toModels() -> [FeedImage] {
    return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
  }
}
