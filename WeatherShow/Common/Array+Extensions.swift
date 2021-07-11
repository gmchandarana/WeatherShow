//
//  Array+Extensions.swift
//  WeatherShow
//
//  Created by Gaurav Chandarana on 12/07/21.
//

import Foundation

extension Array {
    
    subscript(safe index: Int) -> Element? {
        indices ~= index ? self[index]: nil
    }
}
