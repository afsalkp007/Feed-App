//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Afsal on 10/07/2024.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
  public func retrieve() throws -> CachedFeed? {
    try ManagedCache.find(in: context).map {
      CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
    }
  }
  
  public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
    let managedCache = try ManagedCache.newUniqueInstance(in: context)
    managedCache.timestamp = timestamp
    managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
    
    try context.save()
   }
  
  public func deleteCachedFeed() throws {
    try ManagedCache.deleteCache(in: context)
   }
}
