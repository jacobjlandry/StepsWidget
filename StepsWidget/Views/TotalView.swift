//
//  TotalView.swift
//  StepsWidget
//
//  Created by Jacob Landry on 9/6/24.
//

import SwiftUI

struct TotalView: View {
    let title: String
    let goal: Goal
    let total: HealthRecord
    let color: Color
    let icon: String
    
    var body: some View {
        VStack {
            Text("\(total.count) \(total.unit)")
                .font(.largeTitle)
        }.frame(maxWidth: .infinity, maxHeight: 150)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 16.0, style: .continuous))
        .overlay(alignment: .topLeading) {
            HStack {
                Image(systemName: "\(icon)")
                    .foregroundStyle(.white)
                Text("\(title)")
            }.padding()
        }
        .overlay(alignment: .bottom) {
            Text(goal.statusMessage(count: total.count)).padding()
        }.padding()
    }
}

#Preview {
    TotalView(title: "Steps", goal: Goal(count: 0, reward: "", goalTimeframe: "weekly", unit: "step", success: "above"), total: HealthRecord(count: 0, date: Date(), unit: ""), color: .orange, icon: "shoe.2")
}
