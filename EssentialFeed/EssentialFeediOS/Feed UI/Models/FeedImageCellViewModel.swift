//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by Afsal on 01/07/2024.
//

import Foundation
import EssentialFeed

final class FeedImageCellViewModel<Image> {
  typealias Observer<T> = (T) -> Void
  
  private var task: FeedImageDataLoaderTask?
  private let model: FeedImage
  private let imageLoader: FeedImageDataLoader
  private let imageTransformer: (Data) -> Image?
  
  init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
    self.model = model
    self.imageLoader = imageLoader
    self.imageTransformer = imageTransformer
  }
  
  var description: String? {
    return model.description
  }
  
  var location: String? {
    return model.location
  }
  
  var hasLocation: Bool {
    return model.location != nil
  }
  
  var imageStateChange: Observer<Image>?
  var imageLoadingStateChange: Observer<Bool>?
  var retryStateChange: Observer<Bool>?
  
  func loadImageData() {
    imageLoadingStateChange?(true)
    retryStateChange?(false)
    
    self.task = imageLoader.loadImageData(from: model.url) { [weak self] result in
      guard let self = self else { return }
      
      let data = try? result.get()
      if let image = data.flatMap(imageTransformer) {
        self.imageStateChange?(image)
      } else {
        self.retryStateChange?(true)
      }
      self.imageLoadingStateChange?(false)
    }
  }
  
  func cancelImageLoad() {
    task?.cancel()
    task = nil
  }
}
