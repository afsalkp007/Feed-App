//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 30/06/2024.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
  func didRequestsData()
}

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
  private let delegate: FeedRefreshViewControllerDelegate
  
  init(delegate: FeedRefreshViewControllerDelegate) {
    self.delegate = delegate
  }
  
  public lazy var view = loadView()
  
  @objc func refresh() {
    delegate.didRequestsData()
  }
  
  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view.beginRefreshing()
    } else {
      view.endRefreshing()
    }
  }
  
  private func loadView() -> UIRefreshControl {
    let view = UIRefreshControl()
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return view
  }
}
