//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Afsal on 31/07/2024.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {
  
  func test_listWithComments() {
    let sut = makeSUT()

    sut.display(comments())

    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "IMAGE_COMMENTS_dark")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_dark_extraExtraExtraLarge")
  }
  
  private func makeSUT() -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
    let controller = storyboard.instantiateInitialViewController() as! ListViewController
    controller.loadViewIfNeeded()
    controller.tableView.showsVerticalScrollIndicator = false
    controller.tableView.showsHorizontalScrollIndicator = false
    return controller
  }
  
  // MARK: - Helpers
  
  private var commentsController: [ImageCommentCellController] {
    [
      ImageCommentCellController(
        model: ImageCommentViewModel(
          message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
          date: "1000 years ago",
          username: "a long long long long long long username"
        )
      ),
      ImageCommentCellController(
        model: ImageCommentViewModel(
          message: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
          date: "10 days ago",
          username: "a username"
        )
      ),
      ImageCommentCellController(
        model: ImageCommentViewModel(
          message: "nice",
          date: "1 hour ago",
          username: "a."
        )
      )
    ]
  }
  
  private func comments() -> [CellController] {
    return commentsController.map { CellController(id: UUID(), $0) }
  }
}
