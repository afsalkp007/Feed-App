//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Afsal on 06/07/2024.
//

import Foundation

public struct FeedErrorViewModel {
  public let message: String?
  
  static var noError: FeedErrorViewModel {
    return FeedErrorViewModel(message: .none)
  }
  
  static func error(_ message: String?) -> FeedErrorViewModel {
    return FeedErrorViewModel(message: message)
  }
}
