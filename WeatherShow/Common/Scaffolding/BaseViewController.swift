//
//  BaseViewController.swift
//  WeatherShow
//
//  Created by Gaurav Chandarana on 11/07/21.
//

import Foundation
import UIKit

protocol ViewControllerProtocol: UIViewController {
    associatedtype ViewModel

    var viewModel: ViewModel! { get set }
}

class BaseViewController<ViewModel>: UIViewController, ViewControllerProtocol {
    
    var viewModel: ViewModel!
    class var identifier: String {
        String(describing: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = getViewModel()
    }
    
    func getViewModel() -> ViewModel {
        fatalError("getViewModel() has not been implemented")
    }
}
