//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Afsal on 06/07/2024.
//

import Foundation

public struct FeedImageViewModel<Image> {
  public let description: String?
  public let location: String?
  public let image: Image?
  public let isLoading: Bool
  public let shouldRetry: Bool
  
  public var hasLocation: Bool {
    return location != nil
  }
}
