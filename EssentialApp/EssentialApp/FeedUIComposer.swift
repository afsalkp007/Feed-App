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
    let presentationAdapter = FeedLoaderPresentationAdapter(
      feedLoader: feedLoader)
    
    let feedController = makeFeedViewController(
      delegate: presentationAdapter,
      title: FeedPresenter.title)
    
    presentationAdapter.presenter = FeedPresenter(
      loadingView: WeakRefVirtualProxy(feedController),
      errorView: WeakRefVirtualProxy(feedController), 
      feedView: FeedViewAdapter(
        feedController: feedController,
        imageLoader: imageLoader)
    )
    
    return feedController
  }
  
  static func makeFeedViewController(delegate: FeedLoaderPresentationAdapter, title: String) -> FeedViewController {
    let bundle = Bundle(for: FeedViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController { coder in
      return FeedViewController(coder: coder, delegate: delegate)
    }
    feedController?.title = title
    return feedController!
  }
}
