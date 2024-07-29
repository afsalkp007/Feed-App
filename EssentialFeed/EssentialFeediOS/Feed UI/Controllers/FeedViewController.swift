//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 27/06/2024.
//

import UIKit
import EssentialFeed

public protocol FeedViewControllerDelegate {
  func didRequestsData()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView, FeedErrorView {
  @IBOutlet public weak var errorView: ErrorView!
  
  private var delegate: FeedViewControllerDelegate?

  private var viewAppearing: ((FeedViewController) -> Void)?
  
  private var tableModel = [FeedImageCellController]() {
    didSet { tableView.reloadData() }
  }
  
  public convenience init?(coder: NSCoder, delegate: FeedViewControllerDelegate) {
    self.init(coder: coder)
    self.delegate = delegate
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    
    viewAppearing = { vc in
      vc.viewAppearing = nil
      vc.refresh()
    }
  }
  
  public override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    
    viewAppearing?(self)
  }
  
  @IBAction private func refresh() {
    delegate?.didRequestsData()
  }
  
  public func display(_ cellControllers: [FeedImageCellController]) {
    tableModel = cellControllers
  }
  
  public func display(_ viewModel: FeedErrorViewModel) {
    errorView.message = viewModel.message
  }

  public func display(_ viewModel: FeedLoadingViewModel) {
    refreshControl?.update(viewModel.isLoading)
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.count
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return cellController(forRowAt: indexPath).view(in: tableView)
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
