//
//  GraphWithTotalView.swift
//  StepsWidget
//
//  Created by Jacob Landry on 9/9/24.
//

import SwiftUI

struct GraphWithTotalView: View {
    
    let title: String
    let goal: Goal
    let total: HealthRecord
    let color: Color
    let icon: String
    let records: [HealthRecord]
    
    var body: some View {
        TotalView(
            title: title,
            goal: goal,
            total: total,
            color: color,
            icon: icon
        )
        LineGraphView(records: records)
    }
}

#Preview {
    GraphWithTotalView(title: "test", goal: Goal(count: 0, reward: "test", goalTimeframe: "1", unit: "test", success: "test"), total: HealthRecord(count: 0, date: Date(), unit: "test"), color: .orange, icon: "shoes.2", records: [])
}
