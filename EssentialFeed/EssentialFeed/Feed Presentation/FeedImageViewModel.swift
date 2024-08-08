//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Afsal on 06/07/2024.
//

import Foundation

public struct FeedImageViewModel {
  public let description: String?
  public let location: String?
  
  public var hasLocation: Bool {
    return location != nil
  }
}
