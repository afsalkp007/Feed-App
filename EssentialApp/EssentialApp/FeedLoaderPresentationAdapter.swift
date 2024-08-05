//
//  FeedPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Afsal on 04/07/2024.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
  private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
  var presenter: FeedPresenter?
  private var cancellable: Cancellable?
  
  init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
    self.feedLoader = feedLoader
  }
  
  func didRequestsData() {
    presenter?.didStartLoading()
    
    cancellable = feedLoader()
      .dispatchOnMainQueue()
      .sink(
        receiveCompletion: { [weak self] completion in
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
