//
//  HealthRecord.swift
//  StepsWidget
//
//  Created by Jacob Landry on 9/6/24.
//

import Foundation

struct HealthRecord: Identifiable {
    let id = UUID()
    var count: Int
    let date: Date
    let unit: String
}
