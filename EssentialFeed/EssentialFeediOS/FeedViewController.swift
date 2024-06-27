//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 27/06/2024.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
  private var loader: FeedLoader?
  private var viewIsAppearing: ((FeedViewController) -> Void)?

  public convenience init(loader: FeedLoader) {
    self.init()
    self.loader = loader
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    
    viewIsAppearing = { vc in
      vc.viewIsAppearing = nil
      vc.load()
    }
  }
  
  public override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    
    viewIsAppearing?(self)
  }

  @objc private func load() {
    refreshControl?.beginRefreshing()
    loader?.load { [weak self] _ in
      self?.refreshControl?.endRefreshing()
    }
  }
}
