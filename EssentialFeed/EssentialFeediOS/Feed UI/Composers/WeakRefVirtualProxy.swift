//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Afsal on 04/07/2024.
//

import UIKit
import EssentialFeed

final class WeakRefVirtualProxy<T: AnyObject> {
  private weak var object: T?
  
  init(_ object: T?) {
    self.object = object
  }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel) {
    object?.display(viewModel)
  }
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
  func display(_ viewModel: FeedErrorViewModel) {
    object?.display(viewModel)
  }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
  func display(_ viewModel: FeedImageViewModel<UIImage>) {
    object?.display(viewModel)
  }
}