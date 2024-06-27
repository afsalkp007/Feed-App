//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Afsal on 10/06/2024.
//

import Foundation
import EssentialFeed

func anyURL() -> URL {
  return URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
  return NSError(domain: "any error", code: 0)
}

