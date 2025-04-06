//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Afsal on 02/06/2024.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
  let session: URLSession
  
  public init(session: URLSession) {
    self.session = session
  }
  
  private struct UnexpectedValuesRepresentation: Error {}
}

extension URLSessionHTTPClient {
  private struct URLSessionTaskWrapper: HTTPClientTask {
    let wrapper: URLSessionTask
    
    func cancel() {
      wrapper.cancel()
    }
  }
  
  @discardableResult
  public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
    let task = session.dataTask(with: url) { data, response, error in
      completion(Result {
        if let error = error {
          throw error
        } else if let data = data, let response = response as? HTTPURLResponse {
          return (data, response)
        } else {
          throw UnexpectedValuesRepresentation()
        }
      })
    }
    task.resume()
    return URLSessionTaskWrapper(wrapper: task)
  }
}
