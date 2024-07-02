//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Afsal on 01/07/2024.
//

import EssentialFeed

protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
  private let loadinView: FeedLoadingView
  private let feedView: FeedView
  
  init(loadinView: FeedLoadingView, feedView: FeedView) {
    self.loadinView = loadinView
    self.feedView = feedView
  }
  
  func didStartLoading() {
    loadinView.display(FeedLoadingViewModel(isLoading: true))
  }
  
  func didFinishLoading(with feed: [FeedImage]) {
    feedView.display(FeedViewModel(feed: feed))
    loadinView.display(FeedLoadingViewModel(isLoading: false))
  }
  
  func didFinishLoading(with error: Error) {
    loadinView.display(FeedLoadingViewModel(isLoading: false))
  }
}
