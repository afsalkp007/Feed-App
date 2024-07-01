//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Afsal on 01/07/2024.
//

import EssentialFeed

final class FeedViewModel {
  private let feedLoader: FeedLoader
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  var onChange: ((FeedViewModel) -> Void)?
  var onLoadFeed: (([FeedImage]) -> Void)?
  
  var isLoading: Bool = false {
    didSet { onChange?(self) }
  }

  func loadFeed() {
    isLoading = true
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.onLoadFeed?(feed)
      }
      self?.isLoading = false
    }
  }
}
