//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Afsal on 30/06/2024.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
  public static func feedComposedWith(
    feedLoader: @escaping () -> FeedLoader.Publisher,
    imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
  ) -> FeedViewController {
    let feedPresentationAdapter = FeedPresentationAdapter(
      feedLoader: { feedLoader().dispatchOnMainQueue() })
    
    let feedController = makeFeedViewController(
      delegate: feedPresentationAdapter,
      title: FeedPresenter.title
    )
    
    feedPresentationAdapter.presenter = FeedPresenter(
      loadingView: WeakRefVirtualProxy(feedController),
      errorView: WeakRefVirtualProxy(feedController), 
      feedView: FeedViewAdapter(
        feedController: feedController,
        imageLoader: { imageLoader($0).dispatchOnMainQueue() })
    )
    
    return feedController
  }
  
  static func makeFeedViewController(delegate: FeedPresentationAdapter, title: String) -> FeedViewController {
    let bundle = Bundle(for: FeedViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController { coder in
      return FeedViewController(coder: coder, delegate: delegate)
    }
    feedController?.title = title
    return feedController!
  }
}
