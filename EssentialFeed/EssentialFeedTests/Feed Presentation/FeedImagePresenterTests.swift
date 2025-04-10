//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 06/07/2024.
//

import XCTest
import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
  func test_map_createsViewModels() {
    let image = uniqueImage()
    
    let viewModel = FeedImagePresenter.map(image)
    
    XCTAssertEqual(viewModel.description, image.description)
    XCTAssertEqual(viewModel.location, image.location)
  }
}
