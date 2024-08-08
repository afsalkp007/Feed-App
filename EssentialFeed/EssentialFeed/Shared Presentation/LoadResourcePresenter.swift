//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Afsal on 06/07/2024.
//

import Foundation

public protocol ResourceView {
  associatedtype ResourceViewViewModel
  
  func display(_ viewModel: ResourceViewViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
  public typealias Mapper = (Resource) throws -> View.ResourceViewViewModel
  
  private let resourceView: View
  private let loadingView: ResourceLoadingView
  private let errorView: ResourceErrorView
  private let mapper: Mapper
  
  public static var loadError: String {
    return NSLocalizedString(
      "GENERIC_CONNECTION_ERROR",
      tableName: "Shared",
      bundle: Bundle(for: Self.self),
      comment: "Title for the errorview"
    )
  }
  
  public init(resourceView: View, loadingView: ResourceLoadingView, errorView: ResourceErrorView, mapper: @escaping Mapper) {
    self.resourceView = resourceView
    self.loadingView = loadingView
    self.errorView = errorView
    self.mapper = mapper
  }
  
  public func didStartLoading() {
    loadingView.display(ResourceLoadingViewModel(isLoading: true))
    errorView.display(ResourceErrorViewModel(message: .none))
  }
  
  public func didFinishLoading(with resource: Resource) {
    do {
      resourceView.display(try mapper(resource))
      loadingView.display(ResourceLoadingViewModel(isLoading: false))
    } catch {
      didFinishLoading(with: error)
    }
  }
  
  public func didFinishLoading(with error: Error) {
    errorView.display(ResourceErrorViewModel(message: Self.loadError))
    loadingView.display(ResourceLoadingViewModel(isLoading: false))
  }
}
