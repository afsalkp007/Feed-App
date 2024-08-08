//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Afsal on 08/07/2024.
//

import Foundation

public class FeedImageDataMapper {
  public enum Error: Swift.Error {
    case invalidData
  }
  
  public static func map(_ data: Data, response: HTTPURLResponse) throws -> Data {
    guard response.isOK && !data.isEmpty else {
      throw Error.invalidData
    }
    
    return data
  }
}
