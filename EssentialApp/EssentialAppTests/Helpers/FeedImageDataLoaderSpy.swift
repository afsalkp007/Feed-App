//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Afsal on 15/07/2024.
//

import Foundation
import EssentialFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
  private var result: Result<Data, Error>?

  func loadImageData(from url: URL) throws -> Data {
    try result?.get() ?? Data()
  }

  func complete(with error: Error, at index: Int = 0) {
    result = .failure(error)
  }

  func complete(with data: Data, at index: Int = 0) {
    result = .success(data)
  }
}
