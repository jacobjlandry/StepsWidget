//
//  Helper.swift
//  StepsWidget
//
//  Created by Jacob Landry on 8/26/24.
//

import Foundation

func isUnderAverage(_ goal: Int, _ count: Int, _ timeframe: Int) -> Bool {
    let average = goal / timeframe
    return count < average
}

func getStepsGoal() -> Int {
    return 60000
}
