//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Afsal on 15/07/2024.
//

import Foundation

public protocol FeedImageDataCache {
  func save(_ data: Data, for url: URL) throws
}
