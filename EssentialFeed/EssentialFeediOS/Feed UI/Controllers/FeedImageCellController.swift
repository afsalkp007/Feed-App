//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 30/06/2024.
//

import UIKit

protocol FeedImageCellControllerDelegate {
  func didRequestsImage()
  func didCancelImageLoad()
}

final class FeedImageCellController: FeedImageView {
  private let delegate: FeedImageCellControllerDelegate
  private var cell: FeedImageCell?
  
  init(delegate: FeedImageCellControllerDelegate) {
    self.delegate = delegate
  }
  
  func view(in tableView: UITableView) -> UITableViewCell {
    self.cell = tableView.dequeueReusableCell()
    delegate.didRequestsImage()
    return cell!
  }
  
  func display(_ viewModel: FeedImageViewModel<UIImage>) {
    cell?.locationContainer.isHidden = !viewModel.hasLocation
    cell?.locationLabel.text = viewModel.location
    cell?.descriptionLabel.text = viewModel.description
    cell?.feedImageView.setImageAnimated(viewModel.image)
    cell?.feedImageContainer.isShimmering = viewModel.isLoading
    cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
    
    cell?.onRetry = { [weak self] in
      self?.delegate.didRequestsImage()
    }
    
    cell?.onReuse = { [weak self]  in
      self?.releaseCellForReuse()
    }
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

