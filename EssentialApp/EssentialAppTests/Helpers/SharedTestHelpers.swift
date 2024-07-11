//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Afsal on 11/07/2024.
//

import Foundation

func anyNSError() -> NSError {
  return NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
  return Data("any data".utf8)
}

func anyURL() -> URL {
  return URL(string: "http://any-url.com")!
}

