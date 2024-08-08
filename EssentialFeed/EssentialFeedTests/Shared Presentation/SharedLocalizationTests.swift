//
//  SharedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Afsal on 04/07/2024.
//

import XCTest
import EssentialFeed

final class SharedLocalizationTests: XCTestCase {
  private class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
  }
  
  func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
    let table = "Shared"
    let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
    assertLocalization(in: bundle, table)
  }
}
