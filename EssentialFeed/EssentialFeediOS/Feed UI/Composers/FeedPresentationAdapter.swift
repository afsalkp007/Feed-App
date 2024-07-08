//
//  FeedPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Afsal on 04/07/2024.
//

import EssentialFeed

final class FeedPresentationAdapter: FeedViewControllerDelegate {
  private let feedLoader: FeedLoader
  var presenter: FeedPresenter?
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  func didRequestsData() {
    presenter?.didStartLoading()
    
    feedLoader.load { [weak self] result in
      switch result {
      case let .success(feed):
        self?.presenter?.didFinishLoading(with: feed)
        
      case .failure:
        self?.presenter?.didFinishLoadingWithError()
      }
    }
  }
}
