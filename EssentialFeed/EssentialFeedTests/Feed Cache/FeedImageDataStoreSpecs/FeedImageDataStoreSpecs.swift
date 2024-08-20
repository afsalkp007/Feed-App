//
//  FeedImageDataStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Afsal on 20/08/2024.
//

import Foundation

protocol FeedImageDataStoreSpecs {
  func test_retrieveImageData_deliversNotFoundWhenEmpty() throws
  func test_retrieveImageData_deliversNotFoundWhenStoredDataURLDoesNotMatch() throws
  func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() throws
  func test_retrieveImageData_deliversLastInsertedValue() throws
}
