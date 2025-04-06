//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Afsal on 06/07/2024.
//

import Foundation

public class FeedImagePresenter {
  public static func map(_ image: FeedImage) -> FeedImageViewModel {
    return FeedImageViewModel(
      description: image.description,
      location: image.location
    )
  }
}
