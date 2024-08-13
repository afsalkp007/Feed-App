//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Afsal on 04/07/2024.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class CommentsViewAdapter: ResourceView {
  private weak var controller: ListViewController?
  
  init(feedController: ListViewController?) {
    self.controller = feedController
  }
  
  func display(_ viewModel: ImageCommentsViewModel) {
    controller?.display(viewModel.comments.map { viewModel in
      CellController(id: viewModel, ImageCommentCellController(model: viewModel))
    })
  }
}

