//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Afsal on 24/06/2024.
//

import Foundation

public final class CodableFeedStore: FeedStore {
  private struct Cache: Codable {
    let feed: [CodableFeedImage]
    let timestamp: Date
    
    var local: [LocalFeedImage] {
      feed.map(\.local)
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

  private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
  private let storeURL: URL
  
  public init(storeURL: URL) {
    self.storeURL = storeURL
  }
  
  public func retrieve(completion: @escaping RetrievalCompletion) {
    perform { storeURL in
      completion(Result {
        guard let data = try? Data(contentsOf: storeURL) else {
          return .none
        }
        
        let decoder = JSONDecoder()
        let cache = try decoder.decode(Cache.self, from: data)
        return CachedFeed(feed: cache.local, timestamp: cache.timestamp)
      })
    }
  }
  
  public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    perform { storeURL in
      completion(Result {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp))
        try encoded.write(to: storeURL)
      })
    }
  }
  
  public func deleteCachedFeed(_ completion: @escaping DeletionCompletion) {
    perform { storeURL in
      completion(Result {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
          return
        }
        
        try FileManager.default.removeItem(at: storeURL)
      })
    }
  }
  
  private func perform(_ action: @escaping (URL) -> Void) {
    queue.async(flags: .barrier) { [storeURL] in
      action(storeURL)
    }
  }
}
