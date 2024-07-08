//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Afsal on 06/07/2024.
//

import XCTest
import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
  
  func test_init_doesNotMessageToView() {
    let (view, _) = makeSUT()
    
    XCTAssertTrue(view.messages.isEmpty)
  }
  
  func test_didStartImageLoading_startsLoading() {
    let model = makeImage()
    let (view, sut) = makeSUT()
    
    sut.didStartImageLoading(for: model)
    
    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(message?.description, model.description)
    XCTAssertEqual(message?.location, model.location)
    XCTAssertEqual(message?.isLoading, true)
    XCTAssertEqual(message?.shouldRetry, false)
    XCTAssertNil(message?.image)
  }
  
  func test_didFinishLoadingWithData_displaysRetryOnFailedImageTransfromation() {
    let model = makeImage()
    let (view, sut) = makeSUT(imageTransformer: fail)

    sut.didFinishLoading(with: Data(), for: model)
    
    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(message?.description, model.description)
    XCTAssertEqual(message?.location, model.location)
    XCTAssertEqual(message?.isLoading, false)
    XCTAssertEqual(message?.shouldRetry, true)
    XCTAssertNil(message?.image)
  }
  
  func test_didFinishLoadingWithData_displaysImageOnSuccessfulTransfromation() {
    let model = makeImage()
    let trasformedData = AnyImage()
    let (view, sut) = makeSUT(imageTransformer: { _ in trasformedData })

    sut.didFinishLoading(with: Data(), for: model)
    
    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(message?.description, model.description)
    XCTAssertEqual(message?.location, model.location)
    XCTAssertEqual(message?.isLoading, false)
    XCTAssertEqual(message?.shouldRetry, false)
    XCTAssertEqual(message?.image, trasformedData)
  }
  
  func test_didFinishLoadingWithError_stopsLoadingAndDisplaysRetry() {
    let model = makeImage()
    let (view, sut) = makeSUT()
    
    sut.didFinishLoading(with: anyNSError(), for: model)
    
    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(message?.description, model.description)
    XCTAssertEqual(message?.location, model.location)
    XCTAssertEqual(message?.isLoading, false)
    XCTAssertEqual(message?.shouldRetry, true)
    XCTAssertNil(message?.image)
  }
  
  func test_didFinishLoadingWithData_stopsLoadingAndDisplaysFeed() {
    let model = makeImage()
    let (view, sut) = makeSUT()
    
    sut.didFinishLoading(with: Data(), for: model)
    
    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(message?.description, model.description)
    XCTAssertEqual(message?.location, model.location)
    XCTAssertEqual(message?.isLoading, false)
    XCTAssertEqual(message?.shouldRetry, true)
    XCTAssertNil(message?.image)
  }
  
  // MARK: - Helpers
  
  private func makeSUT(imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil }, file: StaticString = #filePath, line: UInt = #line) -> (view: ViewSpy, sut: FeedImagePresenter<ViewSpy,AnyImage>) {
    let view = ViewSpy()
    let sut = FeedImagePresenter<ViewSpy,AnyImage >(view: view, imageTransformer: imageTransformer)
    trackForMemoryLeaks(view, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (view, sut)
  }
  
  private var fail: (Data) -> AnyImage? {
    return { _ in nil }
  }
  
  private struct AnyImage: Equatable {}
  
  private class ViewSpy: FeedImageView {
    var messages = [FeedImageViewModel<AnyImage>]()
    
    func display(_ viewModel: FeedImageViewModel<AnyImage>) {
      messages.append(viewModel)
    }
  }
  
  private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
    return FeedImage(id: UUID(), description: description, location: location, url: url)
  }
}
