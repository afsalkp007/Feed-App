//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Afsal on 30/06/2024.
//

import UIKit

final class FeedImageCellController {
  private let viewModel: FeedImageCellViewModel<UIImage>
  
  init(viewModel: FeedImageCellViewModel<UIImage>) {
    self.viewModel = viewModel
  }
  
  func view() -> UITableViewCell {
    let cell = binded(FeedImageCell())
    viewModel.loadImageData()
    return cell
  }
  
  private func binded(_ cell: FeedImageCell) -> FeedImageCell {
    cell.locationContainer.isHidden = !viewModel.hasLocation
    cell.locationLabel.text = viewModel.location
    cell.descriptionLabel.text = viewModel.description
    
    viewModel.imageStateChange = { [weak cell] image in
      cell?.feedImageView.image = image
    }
    
    viewModel.imageLoadingStateChange = { [weak cell] isLoading in
      cell?.feedImageContainer.isShimmering = isLoading
    }
    
    viewModel.retryStateChange = { [weak cell] shouldRetry in
      cell?.feedImageRetryButton.isHidden = !shouldRetry
    }
    
    cell.onRetry = viewModel.loadImageData
    return cell
  }
  
  func preload() {
    viewModel.loadImageData()
  }
  
  func cancel() {
    viewModel.cancelImageLoad()
  }
}
