//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 30/06/2024.
//

import UIKit
import EssentialFeed

public final class FeedRefreshViewController: NSObject {
  private let feedLoader: FeedLoader
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  public lazy var view: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return refreshControl
  }()
  
  var onRefresh: (([FeedImage]) -> Void)?
  
  @objc func refresh() {
    view.beginRefreshing()
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.onRefresh?(feed)
        self?.view.endRefreshing()

      }
      self?.view.endRefreshing()
    }
  }
}
