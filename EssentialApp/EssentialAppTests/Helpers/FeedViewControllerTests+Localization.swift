//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Afsal on 04/07/2024.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedUIIntegrationTests {
  private class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
  }
  
  var loadError: String {
    return LoadResourcePresenter<Any, DummyView>.loadError
  }
  
  var feedTitle: String {
    return FeedPresenter.title
  }
}
