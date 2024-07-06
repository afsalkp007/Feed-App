//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Afsal on 06/07/2024.
//

import Foundation

public protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}

public protocol FeedErrorView {
  func display(_ viewModel: FeedErrorViewModel)
}

public protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}

public final class FeedPresenter {
  private let loadingView: FeedLoadingView
  private let errorView: FeedErrorView
  private let feedView: FeedView
  
  public static var title: String {
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
  
  public init(loadingView: FeedLoadingView, errorView: FeedErrorView, feedView: FeedView) {
    self.loadingView = loadingView
    self.errorView = errorView
    self.feedView = feedView
  }
  
  public func didStartLoading() {
    loadingView.display(FeedLoadingViewModel(isLoading: true))
    errorView.display(FeedErrorViewModel(message: .none))
  }
  
  public func didFinishLoading(with feed: [FeedImage]) {
    feedView.display(FeedViewModel(feed: feed))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
  
  public func didFinishLoadingWithError() {
    errorView.display(FeedErrorViewModel(message: Self.loadError))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
}
