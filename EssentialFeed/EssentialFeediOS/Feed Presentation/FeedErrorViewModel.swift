//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Afsal on 06/07/2024.
//

import Foundation

struct FeedErrorViewModel {
  let message: String?
  
  static var noError: FeedErrorViewModel {
    return FeedErrorViewModel(message: .none)
  }
  
  static func error(_ message: String) -> FeedErrorViewModel {
    return FeedErrorViewModel(message: message)
  }
}
