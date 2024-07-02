//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Afsal on 02/07/2024.
//

import Foundation

struct FeedImageViewModel<Image> {
  var description: String?
  var location: String?
  var image: Image?
  var isLoading: Bool
  var shouldRetry: Bool
  
  var hasLocation: Bool {
    return location != nil
  }
}
