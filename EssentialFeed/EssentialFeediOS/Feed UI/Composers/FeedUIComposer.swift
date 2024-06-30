//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Afsal on 30/06/2024.
//

import EssentialFeed

public final class FeedUIComposer {
  public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let refreshViewController = FeedRefreshViewController(feedLoader: feedLoader)
    let feedController = FeedViewController(refreshViewController: refreshViewController)
    refreshViewController.onRefresh = adapt(feedController, imageLoader: imageLoader)
    return feedController
  }
  
  private static func adapt(_ feedController: FeedViewController, imageLoader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
    return { [weak feedController] feed in
      feedController?.tableModel = feed.map { model in
        FeedImageCellController(model: model, imageLoader: imageLoader)
      }
    }
  }
}
