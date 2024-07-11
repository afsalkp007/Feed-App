//
//  FeedLoaderFallbackComposite.swift
//  EssentialApp
//
//  Created by Afsal on 11/07/2024.
//

import EssentialFeed

public class FeedLoaderFallbackComposite: FeedLoader {
  private let primary: FeedLoader
  private let fallback: FeedLoader
  
  public init(primary: FeedLoader, fallback: FeedLoader) {
    self.primary = primary
    self.fallback = fallback
  }
  
  public func load(completion: @escaping (FeedLoader.Result) -> Void) {
    primary.load { [weak self] result in
      switch result {
      case .success:
        completion(result)
        
      case .failure:
        self?.fallback.load(completion: completion)
      }
    }
  }
}

