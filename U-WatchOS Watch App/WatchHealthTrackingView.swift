//
//  WatchHealthTrackingView.swift
//  U-WatchOS Watch App
//
//  Created by Avanish Singh on 14.02.25.
//

import SwiftUI
import HealthKit

// MARK: - HealthStoreManager
class HealthStoreManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    // Published properties for each metric
    @Published var heartRate: Double = 0
    @Published var stepCount: Double = 0
    @Published var sleepAnalysis: String = "No Data"
    @Published var basalEnergy: Double = 0       // Calories (Basal Energy Burned)
    @Published var activeEnergy: Double = 0        // Activity Energy Burned
    @Published var respiratoryRate: Double = 0     // breaths per minute
    @Published var bodyMass: Double = 0            // Weight in kg
    @Published var height: Double = 0              // Height in meters
    
    init() {
        requestAuthorization()
        fetchLatestHeartRate()
        fetchStepCount()
        fetchSleepAnalysis()
        fetchBasalEnergy()
        fetchActiveEnergy()
        fetchRespiratoryRate()
        fetchBodyMass()
        fetchHeight()
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        // Define the HealthKit types to read
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate),
              let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
              let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
              let basalEnergyType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned),
              let respiratoryRateType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate),
              let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass),
              let heightType = HKQuantityType.quantityType(forIdentifier: .height)
        else { return }
        
        let typesToRead: Set<HKObjectType> = [
            heartRateType, stepCountType, sleepType,
            activeEnergyType, basalEnergyType, respiratoryRateType,
            bodyMassType, heightType
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if !success {
                print("HealthKit authorization failed: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
    
    // Fetch the most recent heart rate sample
    func fetchLatestHeartRate() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] query, results, error in
            if let sample = results?.first as? HKQuantitySample {
                let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                DispatchQueue.main.async {
                    self?.heartRate = bpm
                }
            }
        }
        healthStore.execute(query)
    }
    
    // Fetch the cumulative step count for today
    func fetchStepCount() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let calendar = Calendar.current
        let now = Date()
        guard let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] query, statistics, error in
            let steps = statistics?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            DispatchQueue.main.async {
                self?.stepCount = steps
            }
        }
        healthStore.execute(query)
    }
    
    // Fetch the most recent sleep sample and calculate duration in hours
    func fetchSleepAnalysis() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] query, results, error in
            if let sample = results?.first as? HKCategorySample {
                if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                    let duration = sample.endDate.timeIntervalSince(sample.startDate)
                    let hours = duration / 3600
                    DispatchQueue.main.async {
                        self?.sleepAnalysis = String(format: "%.1f hrs", hours)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.sleepAnalysis = "In Bed"
                    }
                }
            }
        }
        healthStore.execute(query)
    }
    
    // Fetch cumulative basal energy burned for today (Calories)
    func fetchBasalEnergy() {
        guard let basalEnergyType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned) else { return }
        let calendar = Calendar.current
        let now = Date()
        guard let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(
            quantityType: basalEnergyType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] query, statistics, error in
            let energy = statistics?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            DispatchQueue.main.async {
                self?.basalEnergy = energy
            }
        }
        healthStore.execute(query)
    }
    
    // Fetch cumulative active energy burned for today
    func fetchActiveEnergy() {
        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let calendar = Calendar.current
        let now = Date()
        guard let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(
            quantityType: activeEnergyType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] query, statistics, error in
            let energy = statistics?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            DispatchQueue.main.async {
                self?.activeEnergy = energy
            }
        }
        healthStore.execute(query)
    }
    
    // Fetch the most recent respiratory rate sample (breaths per minute)
    func fetchRespiratoryRate() {
        guard let respiratoryRateType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) else { return }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: respiratoryRateType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] query, results, error in
            if let sample = results?.first as? HKQuantitySample {
                let rr = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                DispatchQueue.main.async {
                    self?.respiratoryRate = rr
                }
            }
        }
        healthStore.execute(query)
    }
    
    // Fetch the most recent body mass sample (weight in kg)
    func fetchBodyMass() {
        guard let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: bodyMassType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] query, results, error in
            if let sample = results?.first as? HKQuantitySample {
                let mass = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                DispatchQueue.main.async {
                    self?.bodyMass = mass
                }
            }
        }
        healthStore.execute(query)
    }
    
    // Fetch the most recent height sample (in meters)
    func fetchHeight() {
        guard let heightType = HKQuantityType.quantityType(forIdentifier: .height) else { return }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: heightType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] query, results, error in
            if let sample = results?.first as? HKQuantitySample {
                let heightValue = sample.quantity.doubleValue(for: HKUnit.meter())
                DispatchQueue.main.async {
                    self?.height = heightValue
                }
            }
        }
        healthStore.execute(query)
    }
}

// MARK: - Reusable Card View for Displaying Metrics (Optimized for Watch)
struct HealthDataCardView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(white: 0.95, opacity: 1.0))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 4)
    }
}

// MARK: - Main Watch Health Tracking View
struct WatchHealthTrackingView: View {
    @StateObject private var healthStore = HealthStoreManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                HealthDataCardView(
                    title: "Heart Rate",
                    value: String(format: "%.0f BPM", healthStore.heartRate)
                )
                HealthDataCardView(
                    title: "Steps",
                    value: String(format: "%.0f", healthStore.stepCount)
                )
                HealthDataCardView(
                    title: "Sleep",
                    value: healthStore.sleepAnalysis
                )
                HealthDataCardView(
                    title: "Basal Energy",
                    value: String(format: "%.0f kcal", healthStore.basalEnergy)
                )
                HealthDataCardView(
                    title: "Respiratory Rate",
                    value: String(format: "%.1f bpm", healthStore.respiratoryRate)
                )
                HealthDataCardView(
                    title: "Activity Energy",
                    value: String(format: "%.0f kcal", healthStore.activeEnergy)
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text("Body Measurements")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text("Weight: \(String(format: "%.1f", healthStore.bodyMass)) kg")
                        .font(.caption2)
                    Text("Height: \(String(format: "%.2f", healthStore.height)) m")
                        .font(.caption2)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(white: 0.95, opacity: 1.0))
                )
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .padding(.horizontal, 4)
            }
            .padding(.top, 8)
        }
        .navigationTitle("Health Data")
    }
}

// MARK: - Watch App Entry Point
//@main
//struct U_WatchOS_Watch_AppApp: App {
//    var body: some Scene {
//        WindowGroup {
//            WatchHealthTrackingView()
//        }
//    }
//}

struct WatchHealthTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        WatchHealthTrackingView()
    }
}
