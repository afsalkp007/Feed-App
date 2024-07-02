//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Afsal on 30/06/2024.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
  public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let adapter = FeedPresentationAdapter(feedLoader: feedLoader)
    let refreshViewController = FeedRefreshViewController(delegate: adapter)
    let feedController = FeedViewController(refreshViewController: refreshViewController)
    
    adapter.presenter = FeedPresenter(
      loadinView: WeakRefVirtualProxy(refreshViewController),
      feedView: FeedViewAdapter(feedController: feedController, imageLoader: imageLoader)
    )
    
    return feedController
  }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
  private weak var object: T?
  
  init(_ object: T?) {
    self.object = object
  }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel) {
    object?.display(viewModel)
  }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
  func display(_ viewModel: FeedImageViewModel<UIImage>) {
    object?.display(viewModel)
  }
}

private final class FeedViewAdapter: FeedView {
  weak var feedController: FeedViewController?
  private let imageLoader: FeedImageDataLoader
  
  init(feedController: FeedViewController?, imageLoader: FeedImageDataLoader) {
    self.feedController = feedController
    self.imageLoader = imageLoader
  }
  
  func display(_ viewModel: FeedViewModel) {
    feedController?.tableModel = viewModel.feed.map { model in
      
      let adapter = FeedImagePresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
      let view = FeedImageCellController(delegate: adapter)
      adapter.presenter = FeedImagePresenter(
        view: WeakRefVirtualProxy(view),
        imageTransformer: UIImage.init
      )

      return view
    }
  }
}

private final class FeedPresentationAdapter: FeedRefreshViewControllerDelegate {
  private let feedLoader: FeedLoader
  var presenter: FeedPresenter?
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  func didRequestsData() {
    presenter?.didStartLoading()
    
    feedLoader.load { [weak self] result in
      switch result {
      case let .success(feed):
        self?.presenter?.didFinishLoading(with: feed)
        
      case let .failure(error):
        self?.presenter?.didFinishLoading(with: error)
      }
    }
  }
}

private final class FeedImagePresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
  private var task: FeedImageDataLoaderTask?
  private let model: FeedImage
  private let imageLoader: FeedImageDataLoader
  
  var presenter: FeedImagePresenter<View, Image>?

  init(model: FeedImage, imageLoader: FeedImageDataLoader) {
    self.model = model
    self.imageLoader = imageLoader
  }
  
  func didRequestsImage() {
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
  
  func didCancelImageLoad() {
    task?.cancel()
    task = nil
  }
}
