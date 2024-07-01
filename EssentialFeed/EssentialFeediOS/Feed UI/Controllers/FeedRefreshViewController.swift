//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 30/06/2024.
//

import UIKit

public final class FeedRefreshViewController: NSObject {
  private let viewModel: FeedViewModel
  
  init(viewModel: FeedViewModel) {
    self.viewModel = viewModel
  }
  
  public lazy var view = binded(UIRefreshControl())
  
  @objc func refresh() {
    viewModel.loadFeed()
  }
  
  private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
    viewModel.onLoadingSateChange = { [weak self] isLoading in
      if isLoading {
        self?.view.beginRefreshing()
      } else {
        self?.view.endRefreshing()
      }
    }
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return view
  }
}
