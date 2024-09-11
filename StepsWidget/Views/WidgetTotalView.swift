//
//  WidgetTotalView.swift
//  StepsWidget
//
//  Created by Jacob Landry on 9/10/24.
//

import SwiftUI

struct WidgetTotalView: View {
    let title: String
    let goal: Goal
    let total: HealthRecord
    let color: Color
    let icon: String
    
    var body: some View {
        VStack {
            Text("\(total.count)")
                .font(.title)
                .foregroundStyle(color)
        }.frame(maxWidth: .infinity, maxHeight: 150)
        .clipShape(RoundedRectangle(cornerRadius: 16.0, style: .continuous))
        .overlay(alignment: .topLeading) {
            HStack {
                Image(systemName: "\(icon)")
                    .foregroundStyle(color)
                Text("\(title)").foregroundStyle(color)
            }.padding()
        }.overlay(alignment: .bottom) {
            HStack {
                Image(systemName: "trophy")
                    .foregroundStyle(color)
                Text(goal.widgetStatusMessage(count: total.count)).foregroundStyle(color)
            }
        }
    }
}

#Preview {
    WidgetTotalView(title: "Steps", goal: Goal(count: getStepsGoal(), reward: "", goalTimeframe: "weekly", unit: "step", success: "above"), total: HealthRecord(count: 8537, date: Date(), unit: ""), color: .orange, icon: "shoe.2")
}
