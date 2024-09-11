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
    
    @State var healthStore = HealthStore()
    
    var body: some View {
        TotalView(title: title, goal: goal, total: total, color: color, icon: icon)
        
        ListView(records: records, goal: goal, recordGoals: recordGoals, timeframe: timeframe)
        
        switch(total.unit) {
        case "oz":
            HStack(spacing: 60) {
                Button {
                    Task {
                        self.healthStore.logWater(ounces: 8)
                    }
                } label: {
                    Label(
                        title: { Text("8oz") },
                        icon: { Image(systemName: "drop") }
                    ).foregroundColor(.blue).padding()
                }
                
                Button {
                    Task {
                        self.healthStore.logWater(ounces: 12)
                    }
                } label: {
                    Label(
                        title: { Text("12oz") },
                        icon: { Image(systemName: "drop") }
                    ).foregroundColor(.blue).padding()
                }
            }
        case "mg":
            HStack(spacing: 60) {
                Button {
                    Task {
                        self.healthStore.logCaffeine(milligrams: 90)
                    }
                } label: {
                    Label(
                        title: { Text("8oz") },
                        icon: { Image(systemName: "cup.and.saucer") }
                    ).foregroundColor(.red).padding()
                }
                
                Button {
                    Task {
                        self.healthStore.logCaffeine(milligrams: 135)
                    }
                } label: {
                    Label(
                        title: { Text("12oz") },
                        icon: { Image(systemName: "cup.and.saucer") }
                    ).foregroundColor(.red).padding()
                }
            }
        default:
            Text("")
        }
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
