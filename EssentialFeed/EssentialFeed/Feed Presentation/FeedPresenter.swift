//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Afsal on 06/07/2024.
//

import Foundation

public final class FeedPresenter {
  public static var title: String {
    NSLocalizedString(
      "FEED_VIEW_TITLE",
      tableName: "Feed",
      bundle: Bundle(for: Self.self),
      comment: "Title for the feed view"
    )
  }
}
