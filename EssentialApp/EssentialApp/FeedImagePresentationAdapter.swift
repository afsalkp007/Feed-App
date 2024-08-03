//
//  FeedImagePresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Afsal on 04/07/2024.
//

import Combine
import Foundation
import EssentialFeed
import EssentialFeediOS

public final class FeedImagePresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {  private let model: FeedImage
  private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
  var cancellable: AnyCancellable?
  
  var presenter: FeedImagePresenter<View, Image>?

  public init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
    self.model = model
    self.imageLoader = imageLoader
  }
  
  public func didRequestsImage() {
    presenter?.didStartImageLoading(for: model)
    
    let model = self.model
    
    cancellable = imageLoader(model.url).sink(receiveCompletion: { [weak self] completion in
      switch completion {
      case .finished: break
        
      case let .failure(error):
        self?.presenter?.didFinishLoading(with: error, for: model)
      }
      
    }, receiveValue: { [weak self] data in
      self?.presenter?.didFinishLoading(with: data, for: model)
    })
  }
  
  public func didCancelImageLoad() {
    cancellable?.cancel()
    cancellable = nil
  }
}
