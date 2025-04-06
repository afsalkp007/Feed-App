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

public final class FeedImageCellController: ResourceView, ResourceLoadingView, ResourceErrorView {
  public typealias ResourceViewViewModel = UIImage
  
  private let viewModel: FeedImageViewModel
  private let delegate: FeedImageCellControllerDelegate
  private var cell: FeedImageCell?
  
  public init(
    viewModel: FeedImageViewModel,
    delegate: FeedImageCellControllerDelegate
  ) {
    self.delegate = delegate
    self.viewModel = viewModel
  }
  
  func view(in tableView: UITableView) -> UITableViewCell {
    self.cell = tableView.dequeueReusableCell()
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
  
  public func display(_ image: UIImage) {
    cell?.feedImageView.setImageAnimated(image)
  }
  
  public func display(_ viewModel: ResourceLoadingViewModel) {
    cell?.feedImageContainer.isShimmering = viewModel.isLoading
  }
  
  public func display(_ viewModel: ResourceErrorViewModel) {
    cell?.feedImageRetryButton.isHidden = viewModel.message == nil
  }
  
  func preload() {
    delegate.didRequestsImage()
  }
  
  func cancel() {
    releaseCellForReuse()
    delegate.didCancelImageLoad()
  }
  
  func releaseCellForReuse() {
    cell?.onReuse  = nil
    cell = nil
  }
}

