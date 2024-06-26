//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Afsal on 23/06/2024.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
  return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
  let models = [uniqueImage()]
  let local = models.map(\.local)
  return (models, local)
}

extension Date {
  private var feedCacheMaxAgeInDays: Int { 7 }
  
  func minusFeedCacheMaxAge() -> Date {
    adding(days: -feedCacheMaxAgeInDays)
  }
  
  private func adding(days: Int) -> Date {
    let calendar = Calendar(identifier: .gregorian)
    return calendar.date(byAdding: .day, value: days, to: self)!
  }
}
 
extension Date {
  func adding(seconds: TimeInterval) -> Date {
    return self + seconds
  }
}


