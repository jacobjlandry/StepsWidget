//
//  ListView.swift
//  StepsWidget
//
//  Created by Jacob Landry on 9/6/24.
//

import SwiftUI

struct ListView: View {
    
    let records: [HealthRecord]
    let goal: Goal
    let recordGoals: Bool
    let timeframe: Int
    
    var body: some View {
        if(recordGoals) {
            List(records) { row in
                HStack {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(isUnderAverage(goal.count, row.count, timeframe) ? .red: .green)
                        
                    Text("\(row.count) \(row.unit)")
                    Spacer()
                    Text(row.date.formatted(date: .complete, time: .omitted))
                }
            }.listStyle(.plain)
        } else {
            List(records) { row in
                HStack {
                    Text("\(row.count) \(row.unit)")
                    Spacer()
                    Text(row.date.formatted(date: .omitted, time: .complete))
                }
            }.listStyle(.plain)
        }
    }
}

#Preview {
    ListView(records: [], goal: Goal(count: 0, reward: "", goalTimeframe: "weekly", unit: "step", success: "above"), recordGoals: false, timeframe: 7)
}

