//
//  Steps_QuickView.swift
//  Steps QuickView
//
//  Created by Jacob Landry on 9/9/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    @State var healthStore = HealthStore()
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<StepsQuickView>) -> Void) {
        Task {
            do {
                try await self.healthStore.calculateSteps()
            } catch {
                print(error)
            }
        }
        
        var entries: [StepsQuickView] = []
        let stepCount = self.healthStore.totalSteps.count;
        if(stepCount > 0) {
            let stepGoal = Goal(count: getStepsGoal(), reward: "Have a Beer!", goalTimeframe: "weekly", unit: "step", success: "above")
            let stepRecord = HealthRecord(count: stepCount, date: Date(), unit: "steps")
            let entry = StepsQuickView(date: Date(), record: stepRecord, goal: stepGoal)
            print(stepRecord.count)
            entries.append(entry)
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
            return
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> StepsQuickView {
        StepsQuickView(date: Date(), record: HealthRecord(count: 8573, date: Date(), unit: "step"), goal: Goal(count: getStepsGoal(), reward: "Test", goalTimeframe: "weekly", unit: "step", success: "above"))
    }

    func getSnapshot(in context: Context, completion: @escaping (StepsQuickView) -> ()) {
        let entry = StepsQuickView(date: Date(), record: HealthRecord(count: 8573, date: Date(), unit: "step"), goal: Goal(count: getStepsGoal(), reward: "Have a Beer!", goalTimeframe: "weekly", unit: "step", success: "above"))
        completion(entry)
    }
}

struct StepsQuickView: TimelineEntry {
    var date: Date
    var record: HealthRecord
    var goal: Goal
}

struct Steps_QuickViewEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        WidgetTotalView(title: "Steps", goal: entry.goal, total: entry.record, color: .orange, icon: "shoe.2")
    }
}

struct Steps_QuickView: Widget {
    let kind: String = "Steps_QuickView"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                Steps_QuickViewEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                Steps_QuickViewEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    Steps_QuickView()
} timeline: {
    StepsQuickView(date: Date(), record: HealthRecord(count: 8573, date: Date(), unit: ""), goal: Goal(count: getStepsGoal(), reward: "Test", goalTimeframe: "weekly", unit: "step", success: "above"))
}
