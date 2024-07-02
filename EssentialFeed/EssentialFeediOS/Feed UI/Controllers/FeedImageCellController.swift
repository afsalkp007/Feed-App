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
  private lazy var cell = FeedImageCell()
  
  init(delegate: FeedImageCellControllerDelegate) {
    self.delegate = delegate
  }
  
  func view() -> UITableViewCell {
    delegate.didRequestsImage()
    return cell
  }
  
  func display(_ viewModel: FeedImageViewModel<UIImage>) {
    cell.locationContainer.isHidden = !viewModel.hasLocation
    cell.locationLabel.text = viewModel.location
    cell.descriptionLabel.text = viewModel.description
    
    cell.feedImageView.image = viewModel.image
    cell.feedImageContainer.isShimmering = viewModel.isLoading
    cell.feedImageRetryButton.isHidden = !viewModel.shouldRetry
    cell.onRetry = delegate.didRequestsImage
  }
  
  func preload() {
    delegate.didRequestsImage()
  }
  
  func cancel() {
    delegate.didCancelImageLoad()
  }
}
