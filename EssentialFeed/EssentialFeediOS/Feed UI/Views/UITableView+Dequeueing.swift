//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Afsal on 03/07/2024.
//

import UIKit

extension UITableView {
  func dequeueReusableCell<T: UITableViewCell>() -> T {
    let identifier = String(describing: T.self)
    return dequeueReusableCell(withIdentifier: identifier) as! T
  }
}
