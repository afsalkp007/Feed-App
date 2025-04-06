//
//  LoadResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 06/07/2024.
//

import XCTest
import EssentialFeed

class LoadResourcePresenterTests: XCTestCase {
  
  func test_init_doesNotSendMessagesToView() {
    let (view, _) = makeSUT()
    
    XCTAssertTrue(view.messages.isEmpty)
  }
  
  func test_didStartLoading_displaysNoErrorMessageAndStartsLoading() {
    let (view, sut) = makeSUT()
    
    sut.didStartLoading()
    
    XCTAssertEqual(view.messages, [
      .display(isLoading: true),
      .display(errorMessage: .none)
    ])
  }
  
  func test_didFinishLoadingWithMapperError_displaysLocalizedErrorMessageAndStopsLoading() {
    let (view, sut) = makeSUT(mapper: { _ in
      throw anyNSError()
    })
    
    sut.didFinishLoading(with: "resource")
    
    XCTAssertEqual(view.messages, [
      .display(errorMessage: localized(key: "GENERIC_CONNECTION_ERROR")),
      .display(isLoading: false)
    ])
  }
  
  func test_didFinishLoadingWithFeed_displaysFeedAndStopsLoading() {
    let (view, sut) = makeSUT(mapper: { resource in
      return resource + " view model"
    })
    
    sut.didFinishLoading(with: "resource")
    
    XCTAssertEqual(view.messages, [
      .display(resourceViewModel: "resource view model"),
      .display(isLoading: false)
    ])
  }
  
  func test_didFinishLoadingWithError_stopsLoadingAndDisplaysError() {
    let (view, sut) = makeSUT()
    
    sut.didFinishLoading(with: anyNSError())
    
    XCTAssertEqual(view.messages, [
      .display(errorMessage: localized(key: "GENERIC_CONNECTION_ERROR")),
      .display(isLoading: false)
    ])
  }
  
  // MARK: - Helpers
  
  private typealias SUT = LoadResourcePresenter<String, ViewSpy>
    
  private func makeSUT(
    mapper: @escaping SUT.Mapper = { _ in "any" },
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> (loader: ViewSpy, sut: SUT) {
    let view = ViewSpy()
    let sut = SUT(
      resourceView: view,
      loadingView: view,
      errorView: view,
      mapper: mapper
    )
    trackForMemoryLeaks(view, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (view, sut)
  }
  
  private func localized(key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
    let table = "Shared"
    let bundle = Bundle(for: SUT.self)
    let value = bundle.localizedString(forKey: key, value: nil, table: table)
    if value == key {
      XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
    }
    return value
  }
  
  private class ViewSpy: ResourceLoadingView, ResourceErrorView, ResourceView {
    typealias ResourceViewViewModel = String
    
    private(set) var messages = Set<Message>()
    
    enum Message: Hashable {
      case display(isLoading: Bool)
      case display(errorMessage: String?)
      case display(resourceViewModel: String)
    }
        
    func display(_ viewModel: ResourceLoadingViewModel) {
      messages.insert(.display(isLoading: viewModel.isLoading))
    }
    
    func display(_ viewModel: ResourceErrorViewModel) {
      messages.insert(.display(errorMessage: viewModel.message))
    }
    
    func display(_ viewModel: String) {
      messages.insert(.display(resourceViewModel: viewModel))
    }
  }
}
