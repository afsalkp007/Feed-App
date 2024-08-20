//
//  XCTestCase+FeedImageDataLoader.swift
//  EssentialAppTests
//
//  Created by Afsal on 15/07/2024.
//

import XCTest
import EssentialFeed

protocol FeedImageDataLoaderTestCase: XCTestCase {}

extension FeedImageDataLoaderTestCase {
  func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: Result<Data, Error>, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    action()
    
    let receivedResult = Result { try sut.loadImageData(from: anyURL()) }
    
    switch (receivedResult, expectedResult) {
    case let (.success(receivedFeed), .success(expectedFeed)):
      XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
      
    case (.failure, .failure):
      break
      
    default:
      XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
    }
  }
}
