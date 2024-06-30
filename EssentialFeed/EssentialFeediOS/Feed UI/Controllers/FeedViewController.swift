//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 27/06/2024.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
  public var refreshViewController: FeedRefreshViewController?

  private var viewAppearing: ((FeedViewController) -> Void)?
  
  var tableModel = [FeedImageCellController]() {
    didSet { tableView.reloadData() }
  }

  public convenience init(refreshViewController: FeedRefreshViewController) {
    self.init()
    self.refreshViewController = refreshViewController
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    refreshControl = refreshViewController?.view
    tableView.prefetchDataSource = self
    
    viewAppearing = { vc in
      vc.viewAppearing = nil
      vc.refreshViewController?.refresh()
    }
  }
  
  public override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    
    viewAppearing?(self)
  }

  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.count
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return cellController(forRowAt: indexPath).view()
  }
  
  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cancelTask(forRowAt: indexPath)
  }
  
  public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    startTask(forRowAt: indexPath)
  }

  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach(startTask)
  }
  
  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach(cancelTask)
  }
  
  private func startTask(forRowAt indexPath: IndexPath) {
    cellController(forRowAt: indexPath).preload()
  }
  
  private func cancelTask(forRowAt indexPath: IndexPath) {
    cellController(forRowAt: indexPath).cancel()
  }
  
  private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
    return tableModel[indexPath.row]
  }

}
