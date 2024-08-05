//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Afsal on 30/05/2024.
//

import Foundation

public final class FeedItemsMapper {
  private struct Root: Decodable {
    private let items: [Item]
    
    private struct Item: Decodable {
      let id: UUID
      let description: String?
      let location: String?
      let image: URL
    }
    
    var feed: [FeedImage] {
      return items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
    }
  }

  private static var OK_200: Int { 200 }
  
  public enum Error: Swift.Error {
    case invalidData
  }
  
  public static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedImage] {
    guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
      throw Error.invalidData
    }
    
    return root.feed
  }
}
