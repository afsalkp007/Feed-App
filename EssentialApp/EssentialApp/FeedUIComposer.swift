//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Afsal on 30/06/2024.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
  public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let feedPresentationAdapter = FeedPresentationAdapter(
      feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
    
    let feedController = makeFeedViewController(
      delegate: feedPresentationAdapter,
      title: FeedPresenter.title
    )
    
    feedPresentationAdapter.presenter = FeedPresenter(
      loadingView: WeakRefVirtualProxy(feedController),
      errorView: WeakRefVirtualProxy(feedController), 
      feedView: FeedViewAdapter(
        feedController: feedController,
        imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader))
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
