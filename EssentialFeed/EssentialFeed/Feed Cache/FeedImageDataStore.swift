//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Afsal on 09/07/2024.
//

import Foundation

public protocol FeedImageDataStore {
  func retrieve(dataForURL url: URL) throws -> Data?
  func insert(_ data: Data, for url: URL) throws
}
