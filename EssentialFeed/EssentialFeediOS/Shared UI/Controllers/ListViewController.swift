//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 27/06/2024.
//

import UIKit
import EssentialFeed

public protocol CellController {
  func view(in tableView: UITableView) -> UITableViewCell
  func preload()
  func cancel()
}

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
  @IBOutlet public weak var errorView: ErrorView!
  
  public var onRefresh: (() -> Void)?

  private var viewAppearing: ((ListViewController) -> Void)?
  
  private var loadingControllers = [IndexPath: CellController]()
  private var tableModel = [CellController]() {
    didSet { tableView.reloadData() }
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    
    viewAppearing = { vc in
      vc.viewAppearing = nil
      vc.refresh()
    }
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    tableView.sizeTableHeaderToFit()
  }
  
  public override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    
    viewAppearing?(self)
  }
  
  @IBAction private func refresh() {
    onRefresh?()
  }
  
  public func display(_ cellControllers: [CellController]) {
    loadingControllers = [:]
    tableModel = cellControllers
  }
  
  public func display(_ viewModel: ResourceErrorViewModel) {
    errorView.message = viewModel.message
  }

  public func display(_ viewModel: ResourceLoadingViewModel) {
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
  
  private func cellController(forRowAt indexPath: IndexPath) -> CellController {
    let controller = tableModel[indexPath.row]
    loadingControllers[indexPath] = controller
    return controller
  }
  
  private func cancelTask(forRowAt indexPath: IndexPath) {
    loadingControllers[indexPath]?.cancel()
    loadingControllers[indexPath] = nil
  }
}
