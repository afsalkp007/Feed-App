//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Afsal on 30/06/2024.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
  public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let viewModel = FeedViewModel(feedLoader: feedLoader)
    let refreshViewController = FeedRefreshViewController(viewModel: viewModel)
    let feedController = FeedViewController(refreshViewController: refreshViewController)
    viewModel.onLoadFeed = adapt(feedController, imageLoader: imageLoader)
    return feedController
  }
  
  private static func adapt(_ feedController: FeedViewController, imageLoader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
    return { [weak feedController] feed in
      feedController?.tableModel = feed.map { model in
        let viewModel = FeedImageCellViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init)
        return FeedImageCellController(viewModel: viewModel)
      }
    }
  }
}
