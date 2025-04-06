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
 
extension LocalFeedLoader: FeedCache {
  public typealias SaveResult = Result<Void, Error>
  
  public func save(_ feed: [FeedImage]) throws {
    try store.deleteCachedFeed()
    try store.insert(feed.toLocal(), timestamp: self.currentDate())
  }
}

extension LocalFeedLoader {
  public func load() throws -> [FeedImage] {
    if let cache = try store.retrieve(), FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()) {
      return cache.feed.toModels()
    }
    return []
  }
}

extension LocalFeedLoader {
  private struct InvalidCache: Error {}

  public func validateCache() throws {
    do {
      if let cache = try store.retrieve(), !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()) {
        throw InvalidCache()
      }
    } catch {
      try store.deleteCachedFeed()
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
