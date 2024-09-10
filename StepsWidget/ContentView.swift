//
//  ContentView.swift
//  StepsWidget
//
//  Created by Jacob Landry on 8/16/24.

import SwiftUI

enum DisplayType: Int, Identifiable, CaseIterable {
    
    case steps
    case water
    case caffeine
    case weight
    case list
    
    var id: Int {
        rawValue
    }
}

extension DisplayType {
    
    var icon: String {
        switch self {
            case .steps:
                return "shoe.2"
            case .water:
                return "drop"
            case .caffeine:
                return "cup.and.saucer"
            case .weight:
                return "figure"
            case .list:
                return "list.bullet"
        }
    }
}

struct ContentView: View {
    
    @State private var healthStore = HealthStore()
    @State private var displayType: DisplayType = .steps
    
    private var steps: [HealthRecord] {
        healthStore.steps.sorted { lhs, rhs in
            lhs.date > rhs.date
        }
    }
    
    private var water: [HealthRecord] {
        healthStore.water.sorted {lhs, rhs in
            lhs.date > rhs.date
        }
    }
    
    private var caffeine: [HealthRecord] {
        healthStore.caffeine.sorted {lhs, rhs in
            lhs.date > rhs.date
        }
    }
    
    private var weight: [HealthRecord] {
        healthStore.weight.sorted {lhs, rhs in
            lhs.date > rhs.date
        }
    }
    
    private var todos: [HealthRecord] {
        return [
            HealthRecord(count: 0, date: Date(), unit: "Brush Teeth"),
            HealthRecord(count: 0, date: Date(), unit: "Feed Pets"),
            HealthRecord(count: 0, date: Date(), unit: "Work Out"),
            HealthRecord(count: 0, date: Date(), unit: "Take Out Trash"),
            HealthRecord(count: 0, date: Date(), unit: "Take Out Recycling"),
            HealthRecord(count: 0, date: Date(), unit: "Clean Bathrooms"),
            HealthRecord(count: 0, date: Date(), unit: "Clean Kitchen"),
            HealthRecord(count: 0, date: Date(), unit: "Read"),
        ]
    }
    
    private var waterGoal: Int {
        return healthStore.totalCaloriesBurned.count > 500 ? 110 : 64
    }
    
    var body: some View {
        let stepGoal = Goal(count: 35000, reward: "Have a Beer!", goalTimeframe: "weekly", unit: "step", success: "above")
        let waterGoal = Goal(count: waterGoal, reward: "", goalTimeframe: "daily", unit: "ounce", success: "above")
        let caffeineGoal = Goal(count: 365, reward: "Slow Down!", goalTimeframe: "daily", unit: "mg", success: "below")
        let weightGoal = Goal(count: 175, reward: "Keep Working!", goalTimeframe: "yearly", unit: "lb", success: "below")
        let todoGoal = Goal(count: 7, reward: "Keep Working!", goalTimeframe: "daily", unit: "item", success: "above")
        VStack {
            Picker("Selection", selection: $displayType) {
                ForEach(DisplayType.allCases) { displayType in
                    Image(systemName: displayType.icon).tag(displayType)
                }
            }
            .pickerStyle(.segmented)
            
            switch displayType {
                case .steps:
                ListWithTotalView(
                    title: "Steps",
                    goal: stepGoal,
                    total: healthStore.totalSteps,
                    color: .orange,
                    icon: "shoe.2",
                    records: steps,
                    recordGoals: true,
                    timeframe: 7
                ).task {
                    do {
                        try await healthStore.calculateSteps()
                    } catch {
                        print(error)
                    }
                }
                case .water:
                ListWithTotalView(
                    title: "Water",
                    goal: waterGoal,
                    total: healthStore.totalWater,
                    color: .blue,
                    icon: "drop",
                    records: water,
                    recordGoals: false,
                    timeframe: 1
                ).task {
                    do {
                        try await healthStore.calculateWater()
                    } catch {
                        print(error)
                    }
                }
                case .caffeine:
                ListWithTotalView(
                    title: "Caffeine",
                    goal: caffeineGoal,
                    total: healthStore.totalCaffeine,
                    color: .red,
                    icon: "cup.and.saucer",
                    records: caffeine,
                    recordGoals: false,
                    timeframe: 1
                ).task {
                    do {
                        try await healthStore.calculateCaffeine()
                    } catch {
                        print(error)
                    }
                }
                case .weight:
                GraphWithTotalView(
                    title: "Weight",
                    goal: weightGoal,
                    total: healthStore.mostRecentWeight,
                    color: .purple,
                    icon: "figure",
                    records: weight
                ).task {
                    do {
                        try await healthStore.calculateWeight()
                    } catch {
                        print(error)
                    }
                }
                case .list:
                ListView(records: todos, goal: todoGoal, recordGoals: true, timeframe: 7)
            }
        }.task {
            await healthStore.requestAuthorization()
        }
        .padding()
        .navigationTitle("Healthy Day")
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
