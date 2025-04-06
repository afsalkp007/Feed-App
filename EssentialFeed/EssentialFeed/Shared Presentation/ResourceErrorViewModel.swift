//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Afsal on 06/07/2024.
//

import Foundation

public struct ResourceErrorViewModel {
  public let message: String?
  
  static var noError: ResourceErrorViewModel {
    return ResourceErrorViewModel(message: .none)
  }
  
  public static func error(_ message: String?) -> ResourceErrorViewModel {
    return ResourceErrorViewModel(message: message)
  }
}
