//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Afsal on 06/07/2024.
//

import Foundation

public struct ImageCommentViewModel: Hashable {
  public let message: String
  public let date: String
  public let username: String
  
  public init(message: String, date: String, username: String) {
    self.message = message
    self.date = date
    self.username = username
  }
}

public struct ImageCommentsViewModel {
  public let comments: [ImageCommentViewModel]
}

public final class ImageCommentsPresenter {
  public static var title: String {
    NSLocalizedString(
      "IMAGE_COMMENTS_VIEW_TITLE",
      tableName: "ImageComments",
      bundle: Bundle(for: Self.self),
      comment: "Title for the image comments view"
    )
  }
  
  public static func map(
    _ comments: [ImageComment],
    currentDate: Date = Date(),
    calendar: Calendar = .current,
    locale: Locale = .current
  ) -> ImageCommentsViewModel {
    let formatter = RelativeDateTimeFormatter()
    formatter.calendar = calendar
    formatter.locale = locale
    
    return ImageCommentsViewModel(comments: comments.map { comment in
      return ImageCommentViewModel(
        message: comment.message,
        date: formatter.localizedString(for: comment.createdAt, relativeTo: currentDate),
        username: comment.username
      )
    })
  }
}
