//
//  HealthStore.swift
//  StepsWidget
//
//  Created by Jacob Landry on 8/16/24.
//

import Foundation
import HealthKit
import Observation

enum HealthError: Error {
    case healthDataNotAvailable
}

@Observable
class HealthStore {
    
    var steps: [HealthRecord] = []
    var water: [HealthRecord] = []
    var caffeine: [HealthRecord] = []
    var burned: [HealthRecord] = []
    var weight: [HealthRecord] = []
    var totalSteps: HealthRecord = HealthRecord(count: 0, date: Date(), unit: "")
    var totalWater: HealthRecord = HealthRecord(count: 0, date: Date(), unit: "oz")
    var totalCaffeine: HealthRecord = HealthRecord(count: 0, date: Date(), unit: "mg")
    var totalCaloriesBurned: HealthRecord = HealthRecord(count: 0, date: Date(), unit: "calories")
    var mostRecentWeight: HealthRecord = HealthRecord(count: 0, date: Date(), unit: "lbs")
    var healthStore: HKHealthStore?
    var lastError: Error?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        } else {
            lastError = HealthError.healthDataNotAvailable
        }
    }
    
    func calculateSteps() async throws {
        guard let healthStore = self.healthStore else { return }
        
        var stepDays:[Date] = []
        
        let calendar = Calendar(identifier: .gregorian)
        
        var stepDate = calendar.nextDate(
            after: calendar.date(byAdding: .day, value: -7, to: Date())!,
            matching: DateComponents(weekday: 1),
            matchingPolicy: .nextTime
        )!
        stepDate = calendar.startOfDay(for: stepDate)
        let endDateTest = Date() // last date

        // get a full list of the dates we want to compare
        stepDays.append(stepDate);
        while stepDate.compare(endDateTest) != .orderedDescending {
            // Advance by one day
            stepDate = calendar.date(byAdding: .day, value: 1, to: stepDate)!
            stepDays.append(stepDate);
        }
        let now = Date();
        
        // reset steps so we don't keep appending
        self.steps = [];
        self.totalSteps = HealthRecord(count: 0, date: Date(), unit: "step")
        let everyDay = DateComponents(day:1)
        var index:Int = 0
        for day in stepDays {
            var tomorrow = now
            if (index < stepDays.count - 1) {
                tomorrow = stepDays[index + 1]
            }
            index += 1
            
            let today = HKQuery.predicateForSamples(withStart: day, end: tomorrow, options: [.strictStartDate])
            let sumOfStepsQuery = HKStatisticsCollectionQuery(quantityType: HKQuantityType(.stepCount), quantitySamplePredicate: today, options: .cumulativeSum, anchorDate: tomorrow, intervalComponents: everyDay)
            
            sumOfStepsQuery.initialResultsHandler = {
                query, results, error in
                
                // Handle errors here.
                if let error = error as? HKError {
                    switch (error.code) {
                    case .errorDatabaseInaccessible:
                        // HealthKit couldn't access the database because the device is locked.
                        return
                    default:
                        // Handle other HealthKit errors here.
                        return
                    }
                }
                
                guard let stepsCount = results else {
                    // You should only hit this case if you have an unhandled error. Check for bugs
                    // in your code that creates the query, or explicitly handle the error.
                    assertionFailure("")
                    return
                }
                
                stepsCount.enumerateStatistics(from: day, to: tomorrow) { statistics, stop in
                    let count = statistics.sumQuantity()?.doubleValue(for: .count())
                    let step = HealthRecord(count: Int(count ?? 0), date: statistics.startDate, unit: "")
                    if(step.count > 0) {
                        self.steps.append(step)
                        self.totalSteps.count = self.steps.map({$0.count}).reduce(0, +)
                        print("Appending \(step.count)")
                        print("New Total \(self.totalSteps.count)")
                    }
                }
            }
            
            healthStore.execute(sumOfStepsQuery)
        }
    }
    
    func calculateWater() async throws {
        // reset water so we don't keep appending
        self.water = [];
        self.totalWater = HealthRecord(count: 0, date: Date(), unit: "oz")
        
        guard let healthStore = self.healthStore else { return }
        let calendar = Calendar(identifier: .gregorian)
        
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        
        let everyHour = DateComponents(hour:1)
        let today = HKQuery.predicateForSamples(withStart: startOfToday, end: now, options: [.strictStartDate])
        let ouncesOfWaterQuery = HKStatisticsCollectionQuery(quantityType: HKQuantityType(.dietaryWater), quantitySamplePredicate: today, options: .cumulativeSum, anchorDate: now, intervalComponents: everyHour)
        
        ouncesOfWaterQuery.initialResultsHandler = {
            query, results, error in
            
            // Handle errors here.
            if let error = error as? HKError {
                switch (error.code) {
                case .errorDatabaseInaccessible:
                    // HealthKit couldn't access the database because the device is locked.
                    return
                default:
                    // Handle other HealthKit errors here.
                    return
                }
            }
            
            guard let waterOunces = results else {
                // You should only hit this case if you have an unhandled error. Check for bugs
                // in your code that creates the query, or explicitly handle the error.
                assertionFailure("")
                return
            }
            
            waterOunces.enumerateStatistics(from: startOfToday, to: now) { statistics, stop in
                let count = statistics.sumQuantity()?.doubleValue(for: .fluidOunceUS())
                let water = HealthRecord(count: Int(count ?? 0), date: statistics.startDate, unit: "oz")
                if(water.count > 0) {
                    self.totalWater.count += water.count
                    self.water.append(water)
                }
            }
        }
        
        healthStore.execute(ouncesOfWaterQuery)
    }
    
    func calculateCaffeine() async throws {
        // reset caffeine so we don't keep appending
        self.caffeine = [];
        self.totalCaffeine = HealthRecord(count: 0, date: Date(), unit: "mg")
        
        guard let healthStore = self.healthStore else { return }
        let calendar = Calendar(identifier: .gregorian)
        
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        
        let everyHour = DateComponents(hour:1)
        let today = HKQuery.predicateForSamples(withStart: startOfToday, end: now, options: [.strictStartDate])
        let mgsOfCaffeine = HKStatisticsCollectionQuery(quantityType: HKQuantityType(.dietaryCaffeine), quantitySamplePredicate: today, options: .cumulativeSum, anchorDate: now, intervalComponents: everyHour)
        
        mgsOfCaffeine.initialResultsHandler = {
            query, results, error in
            
            // Handle errors here.
            if let error = error as? HKError {
                switch (error.code) {
                case .errorDatabaseInaccessible:
                    // HealthKit couldn't access the database because the device is locked.
                    return
                default:
                    // Handle other HealthKit errors here.
                    return
                }
            }
            
            guard let caffeineMgs = results else {
                // You should only hit this case if you have an unhandled error. Check for bugs
                // in your code that creates the query, or explicitly handle the error.
                assertionFailure("")
                return
            }
            
            caffeineMgs.enumerateStatistics(from: startOfToday, to: now) { statistics, stop in
                let count = statistics.sumQuantity()?.doubleValue(for: .gramUnit(with: .milli ))
                let caffeine = HealthRecord(count: Int(count ?? 0), date: statistics.startDate, unit: "mg")
                if(caffeine.count > 0) {
                    self.totalCaffeine.count += caffeine.count
                    self.caffeine.append(caffeine)
                }
            }
        }
        
        healthStore.execute(mgsOfCaffeine)
    }
    
    func calculateActiveCalories() async throws {
        // reset calories so we don't keep appending
        self.burned = [];
        self.totalCaloriesBurned = HealthRecord(count: 0, date: Date(), unit: "calorie")
        
        guard let healthStore = self.healthStore else { return }
        let calendar = Calendar(identifier: .gregorian)
        
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        
        let everyHour = DateComponents(hour:1)
        let today = HKQuery.predicateForSamples(withStart: startOfToday, end: now, options: [.strictStartDate])
        let energyBurned = HKStatisticsCollectionQuery(quantityType: HKQuantityType(.activeEnergyBurned), quantitySamplePredicate: today, options: .cumulativeSum, anchorDate: now, intervalComponents: everyHour)
        
        energyBurned.initialResultsHandler = {
            query, results, error in
            
            // Handle errors here.
            if let error = error as? HKError {
                switch (error.code) {
                case .errorDatabaseInaccessible:
                    // HealthKit couldn't access the database because the device is locked.
                    return
                default:
                    // Handle other HealthKit errors here.
                    return
                }
            }
            
            guard let energy = results else {
                // You should only hit this case if you have an unhandled error. Check for bugs
                // in your code that creates the query, or explicitly handle the error.
                assertionFailure("")
                return
            }
            
            energy.enumerateStatistics(from: startOfToday, to: now) { statistics, stop in
                let count = statistics.sumQuantity()?.doubleValue(for: .kilocalorie())
                let burned = HealthRecord(count: Int(count ?? 0), date: statistics.startDate, unit: "calories")
                if(burned.count > 0) {
                    self.totalCaloriesBurned.count += burned.count
                    self.burned.append(burned)
                }
            }
        }
        
        healthStore.execute(energyBurned)
    }
    
    func calculateWeight() async throws {
        // reset steps so we don't keep appending
        self.weight = [];
        self.mostRecentWeight = HealthRecord(count: 0, date: Date(), unit: "lb")
        
        guard let healthStore = self.healthStore else { return }
        let calendar = Calendar(identifier: .gregorian)
        
        var startDate = calendar.nextDate(
            after: calendar.date(byAdding: .year, value: -3, to: Date())!,
            matching: DateComponents(weekday: 1),
            matchingPolicy: .nextTime
        )!
        startDate = calendar.startOfDay(for: startDate)
        let endDate = Date() // last date
        
        let everyMonth = DateComponents(month:1)
        let thisWeek = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [.strictStartDate])
        let weightQuery = HKStatisticsCollectionQuery(quantityType: HKQuantityType(.bodyMass), quantitySamplePredicate: thisWeek, options: HKStatisticsOptions.mostRecent, anchorDate: endDate, intervalComponents: everyMonth)
        
        weightQuery.initialResultsHandler = {
            query, results, error in
            
            // Handle errors here.
            if let error = error as? HKError {
                switch (error.code) {
                case .errorDatabaseInaccessible:
                    // HealthKit couldn't access the database because the device is locked.
                    return
                default:
                    // Handle other HealthKit errors here.
                    return
                }
            }
            
            guard let pounds = results else {
                // You should only hit this case if you have an unhandled error. Check for bugs
                // in your code that creates the query, or explicitly handle the error.
                assertionFailure("")
                return
            }
            
            pounds.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                let count = statistics.mostRecentQuantity()?.doubleValue(for: .pound())
                let weight = HealthRecord(count: Int(count ?? 0), date: statistics.startDate, unit: "lb")
                if(weight.count > 0) {
                    self.weight.append(weight)
                }
            }
            
            var sortedWeight: [HealthRecord] {
                self.weight.sorted {lhs, rhs in
                    lhs.date > rhs.date
                }
            }
            self.mostRecentWeight = sortedWeight.first!
        }
        
        healthStore.execute(weightQuery)
    }
    
    func logWater(ounces : Double) {
        let quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)
      
        // string value represents US fluid
        let quanitytUnit = HKUnit(from: "fl_oz_us")
        let quantityAmount = HKQuantity(unit: quanitytUnit, doubleValue: ounces)
        let now = Date()
        
        let sample = HKQuantitySample(type: quantityType!, quantity: quantityAmount, start: now, end: now)
        let correlationType = HKObjectType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food)
          
        let waterCorrelationForWaterAmount = HKCorrelation(type: correlationType!, start: now, end: now, objects: [sample])
          
        // Send water intake data to healthStore…aka ‘Health’ app
        self.healthStore?.save(waterCorrelationForWaterAmount, withCompletion: { (success, error) in
            if (error != nil) {
                NSLog("error occurred saving water data")
            }
        })
    }
    
    func logCaffeine(milligrams : Double) {
        let quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryCaffeine)
      
        // string value represents US fluid
        let quanitytUnit = HKUnit(from: "mg")
        let quantityAmount = HKQuantity(unit: quanitytUnit, doubleValue: milligrams)
        let now = Date()
        
        let sample = HKQuantitySample(type: quantityType!, quantity: quantityAmount, start: now, end: now)
        let correlationType = HKObjectType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food)
          
        let caffeineCorrelationForCaffeineAmount = HKCorrelation(type: correlationType!, start: now, end: now, objects: [sample])
          
        // Send water intake data to healthStore…aka ‘Health’ app
        self.healthStore?.save(caffeineCorrelationForCaffeineAmount, withCompletion: { (success, error) in
            if (error != nil) {
                NSLog("error occurred saving caffeine data")
            }
        })
    }
    
    func requestAuthorization() async {
        
        guard let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else { return }
        guard let waterType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater) else { return }
        guard let caffeineType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryCaffeine) else { return }
        guard let weightType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass) else { return }
        guard let activeCalories = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned) else { return }
        guard let healthStore = self.healthStore else { return }
        
        do {
            try await healthStore.requestAuthorization(toShare: [waterType, caffeineType, weightType], read: [stepType, waterType, caffeineType, weightType, activeCalories])
        } catch {
            lastError = error
        }
        
    }
    
}
