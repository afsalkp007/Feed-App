//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Afsal on 23/06/2024.
//

import Foundation

final class FeedCachePolicy {
  private init() {}
  
  private static let calendar = Calendar(identifier: .gregorian)
  private static var maxCacheAge: Int { 7 }
  
  static func validate(_ timestamp: Date, against date: Date) -> Bool {
    guard let maxAge = calendar.date(byAdding: .day, value: maxCacheAge, to: timestamp) else { return false }
    return date < maxAge
  }
}
