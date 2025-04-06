//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Afsal on 15/07/2024.
//

import EssentialFeed

class FeedLoaderStub {
  private let result: Swift.Result<[FeedImage], Error>

  init(result: Swift.Result<[FeedImage], Error>) {
    self.result = result
  }

  func load(completion: @escaping (Swift.Result<[FeedImage], Error>) -> Void) {
    completion(result)
  }
}
