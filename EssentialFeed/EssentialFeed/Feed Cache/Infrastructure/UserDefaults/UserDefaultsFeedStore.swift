//
//  UserDefaultsFeedStore.swift
//  EssentialFeed
//
//  Created by Afsal on 26/06/2024.
//

import Foundation

public final class UserDefaultsFeedStore: FeedStore {
  private let defaults = UserDefaults.standard
  public init() {}
  
  private struct Cache: Codable {
    let feed: [CodableFeedImage]
    let timestamp: Date
    
    var localFeed: [LocalFeedImage] {
      return feed.map(\.local)
    }
  }
  
  private struct CodableFeedImage: Codable {
    private let id: UUID
    private let description: String?
    private let location: String?
    private let url: URL
    
    init(_ image: LocalFeedImage) {
      self.id = image.id
      self.description = image.description
      self.location = image.location
      self.url = image.url
    }
    
    var local: LocalFeedImage {
      return LocalFeedImage(id: id, description: description, location: location, url: url)
    }
  }
  
  public func deleteCachedFeed() throws {
    defaults.removeObject(forKey: "Cache")
  }
  
  public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
    do {
      let encoder = JSONEncoder()
      let encoded = try encoder.encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp))
      defaults.setValue(encoded, forKey: "Cache")
    } catch {
      throw error
    }
  }
  
  public func retrieve() throws -> CachedFeed? {
    let decoder = JSONDecoder()
    do {
      guard let data = defaults.value(forKey: "Cache") as? Data else {
        return .none
      }
      let cache = try decoder.decode(Cache.self, from: data)
      return CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)
    } catch {
      throw error
    }
  }
}
