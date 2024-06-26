//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Afsal on 27/05/2024.
//

import Foundation

public protocol FeedLoader {
  typealias Result = Swift.Result<[FeedImage], Error>
  
  func load(completion: @escaping (Result) -> Void)
}
