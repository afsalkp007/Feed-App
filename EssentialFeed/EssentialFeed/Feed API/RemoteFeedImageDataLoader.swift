//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Afsal on 08/07/2024.
//

import Foundation

public class RemoteFeedImageDataLoader: FeedImageDataLoader {
  private let client: HTTPClient
    
  public init(client: HTTPClient) {
    self.client = client
  }
  
  public enum Error: Swift.Error {
    case connectivity
    case invalidData
  }
  
  private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
    private var completion: ((FeedImageDataLoader.Result) -> Void)?
    
    var wrapped: HTTPClientTask?
    
    init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
      self.completion = completion
    }
    
    func complete(with result: FeedImageDataLoader.Result) {
      completion?(result)
    }
    
    func cancel() {
      preventFurtherCompletions()
      wrapped?.cancel()
    }
    
    private func preventFurtherCompletions() {
      completion = nil
    }
  }
  
  public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
    let task = HTTPClientTaskWrapper(completion)
    
    task.wrapped = client.get(from: url) { [weak self] result in
      guard self != nil else { return }
      
      task.complete(with: result
            .mapError{ _ in return Error.connectivity }
            .flatMap { data, response in
                let isValidResponse = response.isOK && !data.isEmpty
                return isValidResponse ? .success(data) : .failure(Error.invalidData)
            })
    }
    return task
  }
}
