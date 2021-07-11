//
//  SelectDateViewController.swift
//  WeatherShow
//
//  Created by Gaurav Chandarana on 11/07/21.
//

import UIKit

protocol SelectDateViewControllerProtocol: AnyObject {
    func selectDateViewController(_ controller: SelectDateViewController, didSelect date: Date)
    func selectDateViewControllerDidCancel(_ controller: SelectDateViewController)
}

class SelectDateViewController: BaseViewController<SelectDateViewModel> {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    weak var delegate: SelectDateViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.layer.cornerRadius = 8
    }
    
    override func getViewModel() -> SelectDateViewModel {
        SelectDateViewModel()
    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        delegate?.selectDateViewController(self, didSelect: datePicker.date)
    }
    
    @IBAction func cancelButtonAction(_ sender: UIBarButtonItem) {
        delegate?.selectDateViewControllerDidCancel(self)
    }
}
