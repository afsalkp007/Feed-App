//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Afsal on 10/07/2024.
//

import UIKit
import Combine
import CoreData
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  private lazy var httpClient: HTTPClient = {
    URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
  }()

  private lazy var store: FeedStore & FeedImageDataStore = {
    try! CoreDataFeedStore(
      storeURL: NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite"))
  }()
  
  private lazy var localFeedLoader: LocalFeedLoader = {
    LocalFeedLoader(store: store, currentDate: Date.init)
  }()
  
  private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
  
  private lazy var navigationController = UINavigationController(
    rootViewController: FeedUIComposer.feedComposedWith(
      feedLoader: makeRemoteFeedLoaderWithLocalFallback,
      imageLoader: makeLocalImageLoaderWithRemoteFallback,
      selection: showComments))
  
  convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
    self.init()
    self.httpClient = httpClient
    self.store = store
  }
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let scene = (scene as? UIWindowScene) else { return }
    
    window = UIWindow(windowScene: scene)
    configureWindow()
  }
     
  func configureWindow() {
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
  }
  
  private func showComments(for image: FeedImage) {
    let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
    let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
    navigationController.pushViewController(comments, animated: true)
  }
  
  private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
    return { [httpClient] in
      httpClient
        .getPublisher(url: url)
        .tryMap(ImageCommentsMapper.map)
        .eraseToAnyPublisher()
    }
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    localFeedLoader.validateCache { _ in }
  }
  
  private func makeRemoteLoadMoreLoader(last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
    localFeedLoader.loadPublisher()
      .zip(makeRemoteFeedLoader(after: last))
      .map { (cachedItems, newItems) in
        (cachedItems + newItems, newItems.last)
      }.map(makePage)
      .caching(to: localFeedLoader)
  }
  
  private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
    makeRemoteFeedLoader()
      .caching(to: localFeedLoader)
      .fallback(to: localFeedLoader.loadPublisher)
      .map(makeFirstImage)
      .eraseToAnyPublisher()
  }
  
  private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
    let url = FeedEndpoint.get(after: after).url(baseURL: baseURL)
    
    return httpClient
        .getPublisher(url: url)
        .tryMap(FeedItemsMapper.map)
        .eraseToAnyPublisher()
  }
  
  private func makeFirstImage(items: [FeedImage]) -> Paginated<FeedImage> {
    makePage(items: items, last: items.last)
  }
  
  private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
    Paginated(items: items, loadMorePublisher: last.map { last in
      { self.makeRemoteLoadMoreLoader(last: last) }
    })
  }
  
  private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
    let localImageLoader = LocalFeedImageDataLoader(store: store)
    
    return localImageLoader
      .loadImageDataPublisher(from: url)
      .fallback(to: { [httpClient] in
        httpClient
          .getPublisher(url: url)
          .tryMap(FeedImageDataMapper.map)
          .caching(to: localImageLoader, using: url)
      })
  }
}

