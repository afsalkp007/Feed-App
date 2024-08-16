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
  
  private typealias ImagePresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
  private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
  
  init(
    feedController: ListViewController?,
    imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
    selection: @escaping (FeedImage) -> Void
  ) {
    self.controller = feedController
    self.imageLoader = imageLoader
    self.selection = selection
  }
  
  func display(_ viewModel: Paginated<FeedImage>) {
    let feed: [CellController] = viewModel.items.map { model in
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
    }
    
    guard let loadMorePublisher = viewModel.loadMorePublisher else {
      controller?.display(feed)
      return
    }
    
    let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
    let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
    
    loadMoreAdapter.presenter = LoadResourcePresenter(
      resourceView: self,
      loadingView: WeakRefVirtualProxy(loadMore),
      errorView: WeakRefVirtualProxy(loadMore),
      mapper: { $0 })

    let loadMoreSection = [CellController(id: UUID(), loadMore)]
    
    controller?.display(feed, loadMoreSection)
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
