//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Afsal on 15/07/2024.
//

import EssentialFeed

class FeedLoaderStub: FeedLoader {
  private let result: FeedLoader.Result

  init(result: FeedLoader.Result) {
    self.result = result
  }

  func load(completion: @escaping (FeedLoader.Result) -> Void) {
    completion(result)
  }
}
