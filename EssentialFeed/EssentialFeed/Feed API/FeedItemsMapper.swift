//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Afsal on 30/05/2024.
//

import Foundation

final class FeedItemsMapper {
  private struct Root: Decodable {
    let items: [RemoteFeedItem]
  }

  private static var OK_200: Int { 200 }
  
  static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
    guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
      throw RemoteFeedLoader.Error.invalidData
    }
    
    return root.items
  }
}
