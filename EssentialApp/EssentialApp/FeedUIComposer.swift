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
  private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
  
  public static func feedComposedWith(
    feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
    imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
  ) -> FeedViewController {
    let presentationAdapter = FeedPresentationAdapter(
      loader: feedLoader)
    
    let feedController = makeFeedViewController(
      delegate: presentationAdapter,
      title: FeedPresenter.title)
    
    presentationAdapter.presenter = LoadResourcePresenter(
      resourceView: FeedViewAdapter(
        feedController: feedController,
        imageLoader: imageLoader),
      loadingView: WeakRefVirtualProxy(feedController),
      errorView: WeakRefVirtualProxy(feedController),
      mapper: FeedPresenter.map
    )
    
    return feedController
  }
  
  private static func makeFeedViewController(delegate: FeedPresentationAdapter, title: String) -> FeedViewController {
    let bundle = Bundle(for: FeedViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController { coder in
      return FeedViewController(coder: coder, delegate: delegate)
    }
    feedController?.title = title
    return feedController!
  }
}
