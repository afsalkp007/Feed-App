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

func anyData() -> Data {
  return Data("any data".utf8)
}

func makeItemsJSON(_ items: [[String : Any]]) -> Data {
  let json = ["items": items]
  return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
  convenience init(statusCode: Int) {
    self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
  }
}

extension Date {
  func adding(seconds: TimeInterval) -> Date {
    return self + seconds
  }
  
  func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
    return calendar.date(byAdding: .day, value: days, to: self)!
  }
  
  func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
    return calendar.date(byAdding: .minute, value: minutes, to: self)!
  }
}




