//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Afsal on 02/06/2024.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
  let session: URLSession
  
  public init(session: URLSession = .shared) {
    self.session = session
  }
  
  private struct UnexpectedValuesRepresentation: Error {}
  
  
}

extension URLSessionHTTPClient {
  public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    session.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(.failure(error))
      } else if let data = data, let response = response as? HTTPURLResponse {
        completion(.success(data, response))
      } else {
        completion(.failure(UnexpectedValuesRepresentation()))
      }
    }.resume()
  }
}