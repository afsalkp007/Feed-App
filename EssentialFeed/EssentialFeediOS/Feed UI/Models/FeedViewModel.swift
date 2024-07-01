//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Afsal on 01/07/2024.
//

import EssentialFeed

final class FeedViewModel {
  typealias Observer<T> = (T) -> Void
  
  private let feedLoader: FeedLoader
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  var onLoadingSateChange: Observer<Bool>?
  var onLoadFeed: Observer<[FeedImage]>?
  
  func loadFeed() {
    onLoadingSateChange?(true)
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.onLoadFeed?(feed)
      }
      self?.onLoadingSateChange?(false)
    }
  }
}
