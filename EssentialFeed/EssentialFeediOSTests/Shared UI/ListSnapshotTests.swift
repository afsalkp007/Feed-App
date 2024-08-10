//
//  ListSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Afsal on 09/08/2024.
//

import XCTest
import EssentialFeediOS

class ListSnapshotTests: XCTestCase {
  
  func test_emptyFeed() {
    let sut = makeSUT()

    sut.display(emptyList())

    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_LIST_light")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_LIST_dark")
  }
  
  func test_listWithErrorMessage() {
    let sut = makeSUT()

    sut.display(.error("This is a\nmulti-line\nerror message"))

    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
    assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "LIST_WITH_ERROR_MESSAGE_dark_extraExtraExtraLarge")
  }

  // MARK: - Helpers

  private func makeSUT() -> ListViewController {
    let controller = ListViewController()
    controller.loadViewIfNeeded()
    controller.tableView.separatorStyle = .none
    controller.tableView.showsVerticalScrollIndicator = false
    controller.tableView.showsHorizontalScrollIndicator = false
    return controller
  }
  
  private func emptyList() -> [CellController] {
    return []
  }
}
