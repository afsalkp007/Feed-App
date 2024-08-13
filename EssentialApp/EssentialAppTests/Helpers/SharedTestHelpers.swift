//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Afsal on 11/07/2024.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
  return NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
  return Data("any data".utf8)
}

func anyURL() -> URL {
  return URL(string: "http://any-url.com")!
}

func uniqueFeed() -> [FeedImage] {
  return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
}

private class DummyView: ResourceView {
  func display(_ viewModel: Any) {}
}

var loadError: String {
  return LoadResourcePresenter<Any, DummyView>.loadError
}

var feedTitle: String {
  return FeedPresenter.title
}

var commentsTitle: String {
  return ImageCommentsPresenter.title
}


