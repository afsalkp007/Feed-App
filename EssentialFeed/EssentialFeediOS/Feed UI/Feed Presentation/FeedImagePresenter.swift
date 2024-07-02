//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Afsal on 01/07/2024.
//

import Foundation
import EssentialFeed

protocol FeedImageView {
  associatedtype Image
  
  func display(_ viewModel: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
  private let view: View
  private let imageTransformer: (Data) -> Image?
  
  init(view: View, imageTransformer: @escaping (Data) -> Image?) {
    self.view = view
    self.imageTransformer = imageTransformer
  }
  
  func didStartImageLoading(for model: FeedImage) {
    view.display(
      FeedImageViewModel(
        description: model.description,
        location: model.location,
        image: nil,
        isLoading: true,
        shouldRetry: false
      )
    )
  }
  
  private struct ImageLoadingError: Error {}
  
  func didFinishLoading(with data: Data, for model: FeedImage) {
    guard let image = imageTransformer(data) else {
      return didFinishLoading(with: ImageLoadingError(), for: model)
    }
    
    view.display(
      FeedImageViewModel(
        description: model.description,
        location: model.location,
        image: image,
        isLoading: false,
        shouldRetry: false
      )
    )
  }
  
  func didFinishLoading(with error: Error, for model: FeedImage) {
    view.display(
      FeedImageViewModel(
        description: model.description,
        location: model.location,
        image: nil,
        isLoading: false,
        shouldRetry: true
      )
    )
  }
}
