//
//  ListWithTotalView.swift
//  StepsWidget
//
//  Created by Jacob Landry on 9/9/24.
//

import SwiftUI

struct ListWithTotalView: View {
    
    let title: String
    let goal: Goal
    let total: HealthRecord
    let color: Color
    let icon: String
    let records: [HealthRecord]
    let recordGoals: Bool
    let timeframe: Int
    
    var body: some View {
        TotalView(title: title, goal: goal, total: total, color: color, icon: icon)
        
        ListView(records: records, goal: goal, recordGoals: recordGoals, timeframe: timeframe)
    }
}

#Preview {
    ListWithTotalView(
        title: "Test",
        goal: Goal(count: 1, reward: "test", goalTimeframe: "test", unit: "test", success: "test"),
        total: HealthRecord(count: 0, date: Date(), unit: "test"),
        color: .orange,
        icon: "shoe.2",
        records: [],
        recordGoals: false,
        timeframe: 1
    )
}
