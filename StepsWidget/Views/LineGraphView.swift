//
//  LineGraphView.swift
//  StepsWidget
//
//  Created by Jacob Landry on 9/6/24.
//

import SwiftUI
import Charts

struct LineGraphView: View {
    let records: [HealthRecord]
    
    var body: some View {
        Chart {
            ForEach(records) { point in
                LineMark(x: .value("Date", point.date), y: .value("Lbs", point.count))
                    .foregroundStyle(.purple)
            }
        }.chartYScale(domain: [self.getMin() - 5, self.getMax() + 5])
    }
    
    func getMin() -> Int {
        return self.records.map { $0.count }.min() ?? 0
    }
    
    func getMax() -> Int {
        return self.records.map {$0.count}.max() ?? 0
    }
}
