//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 27/06/2024.
//

import UIKit
import EssentialFeed

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
  private(set) public var errorView = ErrorView()
  
  public var onRefresh: (() -> Void)?
  
  private var viewAppearing: ((ListViewController) -> Void)?
  
  private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
    .init(tableView: tableView) { tableView, index, controller in
      return controller.dataSource.tableView(tableView, cellForRowAt: index)
    }
  }()
 
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    configureTableView()
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
  
  private func configureTableView() {
    dataSource.defaultRowAnimation = .fade
    tableView.dataSource = dataSource
    tableView.tableHeaderView = errorView.makeContainer()
    
    errorView.onHide = { [weak self] in
      self?.tableView.beginUpdates()
      self?.tableView.sizeTableHeaderToFit()
      self?.tableView.endUpdates()
    }
  }
  
  @IBAction private func refresh() {
    onRefresh?()
  }
  
  public override func traitCollectionDidChange(_ previous: UITraitCollection?) {
      if previous?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
          tableView.reloadData()
      }
  }
  
  public func display(_ cellControllers: [CellController]) {
    var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
    snapshot.appendSections([0])
    snapshot.appendItems(cellControllers, toSection: 0)
    dataSource.applySnapshotUsingReloadData(snapshot)
  }
  
  public func display(_ viewModel: ResourceErrorViewModel) {
    errorView.message = viewModel.message
  }

  public func display(_ viewModel: ResourceLoadingViewModel) {
    refreshControl?.update(viewModel.isLoading)
  }
  
  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let dl = cellController(at: indexPath)?.delegate
    dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
  }
  
  public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let dl = cellController(at: indexPath)?.delegate
    dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
  }

  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      let dsp = cellController(at: indexPath)?.dataSourcePrefetching
      dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
  }
  
  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      let dsp = cellController(at: indexPath)?.dataSourcePrefetching
      dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
  }
  
  private func cellController(at indexPath: IndexPath) -> CellController? {
    dataSource.itemIdentifier(for: indexPath)
  }
}
