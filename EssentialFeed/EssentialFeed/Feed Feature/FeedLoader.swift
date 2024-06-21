//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Afsal on 27/05/2024.
//

import Foundation

public enum LoadFeedResult {
  case success([FeedImage])
  case failure(Error)
}

public protocol FeedLoader {
  func load(completion: @escaping (LoadFeedResult) -> Void)
}
