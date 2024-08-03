//
//  FeedPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Afsal on 04/07/2024.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedPresentationAdapter: FeedViewControllerDelegate {
  private let feedLoader: () -> FeedLoader.Publisher
  var presenter: FeedPresenter?
  private var cancellable: Cancellable?
  
  init(feedLoader: @escaping () -> FeedLoader.Publisher) {
    self.feedLoader = feedLoader
  }
  
  func didRequestsData() {
    presenter?.didStartLoading()
    
    cancellable = feedLoader().sink(receiveCompletion: { [weak self] completion in
      switch completion {
      case .finished: break
        
      case .failure:
        self?.presenter?.didFinishLoadingWithError()
      }
      
    }, receiveValue: { [weak self] feed in
      self?.presenter?.didFinishLoading(with: feed)
    })
  }
}
