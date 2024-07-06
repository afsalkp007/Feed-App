//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Afsal on 01/07/2024.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}

protocol FeedErrorView {
  func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
  private let loadinView: FeedLoadingView
  private let feedView: FeedView
  private let errorView: FeedErrorView
  
  init(loadinView: FeedLoadingView, feedView: FeedView, errorView: FeedErrorView) {
    self.loadinView = loadinView
    self.feedView = feedView
    self.errorView = errorView
  }
  
  static var title: String {
    return NSLocalizedString(
      "FEED_VIEW_TITLE",
      tableName: "Feed",
      bundle: Bundle(for: FeedPresenter.self),
      comment: "Title for the feed view"
    )
  }
  
  static var loadError: String {
    return NSLocalizedString(
      "FEED_VIEW_CONNECTION_ERROR",
      tableName: "Feed",
      bundle: Bundle(for: FeedPresenter.self),
      comment: "Title for the errorview"
    )
  }
  
  func didStartLoading() {
    errorView.display(.noError)
    loadinView.display(FeedLoadingViewModel(isLoading: true))
  }
  
  func didFinishLoading(with feed: [FeedImage]) {
    feedView.display(FeedViewModel(feed: feed))
    loadinView.display(FeedLoadingViewModel(isLoading: false))
  }
  
  func didFinishLoading(with error: Error) {
    errorView.display(.error(Self.loadError))
    loadinView.display(FeedLoadingViewModel(isLoading: false))
  }
}
