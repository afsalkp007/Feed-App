//
//  FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Afsal on 28/06/2024.
//

import Foundation

public protocol FeedImageDataLoader {
  func loadImageData(from url: URL) throws -> Data
}
