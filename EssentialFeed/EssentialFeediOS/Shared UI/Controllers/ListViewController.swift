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
  
  private var onViewDidAppear: ((ListViewController) -> Void)?
  
  private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
    .init(tableView: tableView) { tableView, index, controller in
      return controller.dataSource.tableView(tableView, cellForRowAt: index)
    }
  }()
 
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    configureTableView()
    configureTraitCollectionObservers()
    onViewDidAppear = { vc in
      vc.onViewDidAppear = nil
      vc.refresh()
    }
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    onViewDidAppear?(self)
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    tableView.sizeTableHeaderToFit()
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
  
  private func configureTraitCollectionObservers() {
    registerForTraitChanges(
      [UITraitPreferredContentSizeCategory.self]
    ) { (self: Self, previous: UITraitCollection) in
      self.tableView.reloadData()
    }
  }
  
  @IBAction private func refresh() {
    onRefresh?()
  }
    
  public func display(_ sections: [CellController]...) {
    var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
    sections.enumerated().forEach { section, cellControllers in
      snapshot.appendSections([section])
      snapshot.appendItems(cellControllers, toSection: section)
    }
    dataSource.applySnapshotUsingReloadData(snapshot)
  }
  
  public func display(_ viewModel: ResourceErrorViewModel) {
    errorView.message = viewModel.message
  }

  public func display(_ viewModel: ResourceLoadingViewModel) {
    refreshControl?.update(viewModel.isLoading)
  }
  
  public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dl = cellController(at: indexPath)?.delegate
    dl?.tableView?(tableView, didSelectRowAt: indexPath)
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
