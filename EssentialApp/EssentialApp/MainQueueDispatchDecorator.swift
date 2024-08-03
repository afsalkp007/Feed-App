//
//  MainQueueDispatchDecorator.swift
//  EssentialFeediOS
//
//  Created by Afsal on 04/07/2024.
//

import Foundation
import EssentialFeed

final class MainQueueDispatchDecorator<T> {
  private let decoratee: T
  
  init(decoratee: T) {
    self.decoratee = decoratee
  }
  
  func dispatch(_ completion: @escaping () -> Void) {
    guard Thread.isMainThread else {
      return DispatchQueue.main.async(execute: completion)
    }
    
    completion()
  }
}
 
extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
  func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
    decoratee.loadImageData(from: url) { [weak self] result in
      self?.dispatch { completion(result) }
    }
  }
}
