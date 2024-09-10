//
//  Goal.swift
//  StepsWidget
//
//  Created by Jacob Landry on 9/6/24.
//

import Foundation

struct Goal: Identifiable {
    let id = UUID()
    let count: Int
    let reward: String
    let goalTimeframe: String
    let unit: String
    let success: String
    
    func statusMessage(count: Int) -> String {
        var statusMessage:String = "";
        if(self.success == "above") {
            if(self.count > count) {
                statusMessage = "You haven't met your \(goalTimeframe) goal of \(self.count) \(self.unit)s yet, keep going!"
            } else {
                statusMessage = "Congratulations! You've met your \(self.goalTimeframe) \(self.unit) goal! \(self.reward)"
            }
        } else {
            if(self.count > count) {
                statusMessage = "You're still below your \(goalTimeframe) limit of \(self.count) \(self.unit)s, great job!"
            } else {
                statusMessage = "You've exceeded your \(self.goalTimeframe) \(self.unit) limit! \(self.reward)"
            }
        }
        
        return statusMessage
    }
}
