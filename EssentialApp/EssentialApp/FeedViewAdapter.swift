//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Afsal on 04/07/2024.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
  private weak var controller: ListViewController?
  private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
  private var selection: (FeedImage) -> Void
  
  init(
    feedController: ListViewController?,
    imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
    selection: @escaping (FeedImage) -> Void
  ) {
    self.controller = feedController
    self.imageLoader = imageLoader
    self.selection = selection
  }
  
  func display(_ viewModel: FeedViewModel) {
    controller?.display(viewModel.feed.map { model in
      typealias ImagePresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
      
      let adapter = ImagePresentationAdapter(loader: { [imageLoader] in
        imageLoader(model.url)
      })
      
      let view = FeedImageCellController(
        viewModel: FeedImagePresenter.map(model),
        delegate: adapter,
        selection: { [selection] in
          selection(model)
        })
      
      adapter.presenter = LoadResourcePresenter(
        resourceView: WeakRefVirtualProxy(view),
        loadingView: WeakRefVirtualProxy(view),
        errorView: WeakRefVirtualProxy(view),
        mapper: UIImage.tryMap)

      return CellController(id: model, view)
    })
  }
  
}

private extension UIImage {
  private struct InvalidImageData: Error {}

  static func tryMap(_ data: Data) throws -> UIImage {
    guard let image = UIImage(data: data) else {
      throw InvalidImageData()
    }
    
    return image
  }
}
