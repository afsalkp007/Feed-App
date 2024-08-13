//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 30/06/2024.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
  func didRequestsImage()
  func didCancelImageLoad()
}

public final class FeedImageCellController: NSObject {
  public typealias ResourceViewViewModel = UIImage
  
  private let viewModel: FeedImageViewModel
  private let delegate: FeedImageCellControllerDelegate
  private let selection: () -> Void
  private var cell: FeedImageCell?
  
  public init(
    viewModel: FeedImageViewModel,
    delegate: FeedImageCellControllerDelegate,
    selection: @escaping () -> Void
  ) {
    self.delegate = delegate
    self.viewModel = viewModel
    self.selection = selection
  }
}
 
extension FeedImageCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
  public func display(_ image: UIImage) {
    cell?.feedImageView.setImageAnimated(image)
  }
  
  public func display(_ viewModel: ResourceLoadingViewModel) {
    cell?.feedImageContainer.isShimmering = viewModel.isLoading
  }
  
  public func display(_ viewModel: ResourceErrorViewModel) {
    cell?.feedImageRetryButton.isHidden = viewModel.message == nil
  }
}

extension FeedImageCellController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    cell = tableView.dequeueReusableCell()
    cell?.locationContainer.isHidden = !viewModel.hasLocation
    cell?.locationLabel.text = viewModel.location
    cell?.descriptionLabel.text = viewModel.description
    
    cell?.onRetry = { [weak self] in
      self?.delegate.didRequestsImage()
    }
    
    cell?.onReuse = { [weak self]  in
      self?.releaseCellForReuse()
    }

    delegate.didRequestsImage()
    return cell!
  }
  
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selection()
  }
  
  public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cancelLoad()
  }
  
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    self.cell = cell as? FeedImageCell
    delegate.didRequestsImage()
  }
  
  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    cancelLoad()
  }
  
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    preload()
  }
  
  private func cancelLoad() {
    releaseCellForReuse()
    delegate.didCancelImageLoad()
  }
  
  private func releaseCellForReuse() {
    cell?.onReuse = nil
    cell = nil
  }
  
  private func preload() {
    delegate.didRequestsImage()
  }
}

