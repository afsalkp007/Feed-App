//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Afsal on 30/06/2024.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class CommentsUIComposer {
  private init() {}
  
  private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>
  
  public static func commentsComposedWith(
    commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>) -> ListViewController {
    let presentationAdapter = CommentsPresentationAdapter(
      loader: commentsLoader)
    
    let commentsController = makeCommentsViewController(
      title: ImageCommentsPresenter.title)
    commentsController.onRefresh = presentationAdapter.loadResource
    
    presentationAdapter.presenter = LoadResourcePresenter(
      resourceView: CommentsViewAdapter(feedController: commentsController),
      loadingView: WeakRefVirtualProxy(commentsController),
      errorView: WeakRefVirtualProxy(commentsController),
      mapper: { ImageCommentsPresenter.map($0) }
    )
    
    return commentsController
  }
  
  private static func makeCommentsViewController(title: String) -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
    let controller = storyboard.instantiateInitialViewController() as! ListViewController
    controller.title = title
    return controller
  }
}
