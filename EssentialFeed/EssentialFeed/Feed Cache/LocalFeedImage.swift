//
//  LocalFeedImage.swift
//  EssentialFeed
//
//  Created by Afsal on 20/06/2024.
//

import Foundation

public struct LocalFeedImage: Equatable {
  public let id: UUID
  public let description: String?
  public let location: String?
  public let url: URL
  
  public init(id: UUID, description: String?, location: String?, url: URL) {
    self.id = id
    self.description = description
    self.location = location
    self.url = url
  }
  
  public init(_ image: FeedImage) {
    self.id = image.id
    self.description = image.description
    self.location = image.location
    self.url = image.url
  }
}
