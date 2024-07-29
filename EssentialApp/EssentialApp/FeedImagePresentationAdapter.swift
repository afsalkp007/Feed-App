//
//  FeedImagePresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Afsal on 04/07/2024.
//

import EssentialFeed
import EssentialFeediOS

public final class FeedImagePresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
  private var task: FeedImageDataLoaderTask?
  private let model: FeedImage
  private let imageLoader: FeedImageDataLoader
  
  var presenter: FeedImagePresenter<View, Image>?

  public init(model: FeedImage, imageLoader: FeedImageDataLoader) {
    self.model = model
    self.imageLoader = imageLoader
  }
  
  public func didRequestsImage() {
    presenter?.didStartImageLoading(for: model)
    
    self.task = imageLoader.loadImageData(from: model.url) { [weak self] result in
      guard let self = self else { return }
      
      switch result {
      case let .success(data):
        self.presenter?.didFinishLoading(with: data, for: model)
        
      case let .failure(error):
        self.presenter?.didFinishLoading(with: error, for: model)
      }
    }
  }
  
  public func didCancelImageLoad() {
    task?.cancel()
    task = nil
  }
}
