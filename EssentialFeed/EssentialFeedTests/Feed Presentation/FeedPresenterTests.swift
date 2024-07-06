//
//  FeedPresenter.swift
//  EssentialFeedTests
//
//  Created by Afsal on 06/07/2024.
//

import XCTest
import EssentialFeed

class FeedPresenterTests: XCTestCase {
  
  func test_title_isLocalized() {
    XCTAssertEqual(FeedPresenter.title, localized(key: "FEED_VIEW_TITLE"))
  }
  
  func test_init_doesNotSendMessagesToView() {
    let (view, _) = makeSUT()
    
    XCTAssertTrue(view.messages.isEmpty)
  }
  
  func test_didStartLoading_startsLoadingAndResetErrorView() {
    let (view, sut) = makeSUT()
    
    sut.didStartLoading()
    
    XCTAssertEqual(view.messages, [
      .display(isLoading: true),
      .display(errorMessage: .none)
    ])
  }
  
  func test_didFinishLoadingWithFeed_stopsLoadingAndDisplaysFeed() {
    let feed = [makeImage()]
    let (view, sut) = makeSUT()
    
    sut.didFinishLoading(with: feed)
    
    XCTAssertEqual(view.messages, [
      .display(feed: feed),
      .display(isLoading: false)
    ])
  }
  
  func test_didFinishLoadingWithError_stopsLoadingAndDisplaysError() {
    let error = localized(key: "FEED_VIEW_CONNECTION_ERROR")
    let (view, sut) = makeSUT()
    
    sut.didFinishLoadingWithError()
    
    XCTAssertEqual(view.messages, [
      .display(errorMessage: error),
      .display(isLoading: false)
    ])
  }
  
  // MARK: - Helpers
  
  private func makeSUT( file: StaticString = #filePath, line: UInt = #line) -> (loader: ViewSpy, sut: FeedPresenter) {
    let view = ViewSpy()
    let sut = FeedPresenter(loadingView: view, errorView: view, feedView: view)
    trackForMemoryLeaks(view, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (view, sut)
  }
  
  private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
    return FeedImage(id: UUID(), description: description, location: location, url: url)
  }
  
  private class ViewSpy: FeedLoadingView, FeedErrorView, FeedView {
    private(set) var messages = Set<Message>()
    
    enum Message: Hashable {
      case display(isLoading: Bool)
      case display(errorMessage: String?)
      case display(feed: [FeedImage])
    }
        
    func display(_ viewModel: FeedLoadingViewModel) {
      messages.insert(.display(isLoading: viewModel.isLoading))
    }
    
    func display(_ viewModel: FeedErrorViewModel) {
      messages.insert(.display(errorMessage: viewModel.message))
    }
    
    func display(_ viewModel: FeedViewModel) {
      messages.insert(.display(feed: viewModel.feed))
    }
  }
}
