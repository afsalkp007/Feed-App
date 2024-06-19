//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Afsal on 19/06/2024.
//

import Foundation

public protocol FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void

  func deleteCachedFeed(_ completion: @escaping DeletionCompletion)
  func insert(_ items: [FeedItem], currentDate: Date, completion: @escaping InsertionCompletion)
}
