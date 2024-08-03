//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Afsal on 04/07/2024.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: FeedView {
  weak var feedController: FeedViewController?
  private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
  
  init(feedController: FeedViewController?, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
    self.feedController = feedController
    self.imageLoader = imageLoader
  }
  
  func display(_ viewModel: FeedViewModel) {
    feedController?.display(viewModel.feed.map { model in
      
      let adapter = FeedImagePresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
      let view = FeedImageCellController(delegate: adapter)
      adapter.presenter = FeedImagePresenter(
        view: WeakRefVirtualProxy(view),
        imageTransformer: UIImage.init
      )

      return view
    })
  }
}
