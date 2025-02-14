# U-Watch & U-WatchOS – Health Tracking Apps

## Overview

U-Watch and U-WatchOS are a suite of health tracking applications designed for the iPhone and Apple Watch. They integrate with Apple HealthKit to read various health metrics such as heart rate, step count, sleep duration, calories (basal energy), respiratory rate, activity energy, and body measurements (weight and height). The iPhone app also includes features for collecting user profile data and questionnaires, while the Apple Watch app displays the health data in a compact, card-based interface optimized for a small screen.

## Features

### iPhone App
1. User Profile:
    - Input personal details (name, sex, age, height, weight, medications).
    - Persist data using SwiftUI’s @AppStorage.

2. Health Tracking:
    - Heart Rate: Displays the most recent heart rate in BPM.
    - Step Count Today: Shows the total steps recorded for the current day.
    - Sleep Analysis: Calculates sleep duration (in hours) from the most recent sample.
    - Calories (Basal Energy): Displays basal energy burned in kcal.
    - Respiratory Rate: Displays breaths per minute from the latest sample.
    - Activity Energy: Shows active energy burned in kcal.
    Body Measurements: Displays weight and height.

3. Questionnaire:
    - Developer-provided questionnaires to gather user input/feedback.

4. Additional Integrations:
    - Uses CoreLocation to potentially fetch user location (if extended in future versions).
    - (Optional) Originally planned to use WeatherKit for weather data based on location, but this feature has been removed in the current version.

### Apple Watch App

1. Watch Health Tracking:
    - Displays key health metrics (heart rate, step count, sleep, calories, respiratory rate, activity energy, and body measurements) using a card-style UI optimized for the watch screen.
    - Uses the same HealthKit data via a shared HealthStoreManager.

## APIs and Frameworks Used

1. SwiftUI:
    - Provides the modern, declarative UI for both iPhone and Apple Watch apps.

2. HealthKit:
    - Retrieves health metrics using:
        - HKSampleQuery for real-time data (e.g., heart rate, respiratory rate).
        - HKStatisticsQuery for cumulative data (e.g., step count, energy burned).

    - Required Info.plist Keys:
        - NSHealthShareUsageDescription
        - NSHealthUpdateUsageDescription
3. CoreLocation:
    - (For potential future location-based features on iPhone.)
    - Required Info.plist Key:
        - NSLocationWhenInUseUsageDescription

4. WatchKit:
    - Enables the Apple Watch app’s interface and functionality.
    - (Optional) WeatherKit:
        - Was considered for fetching weather data based on location, but this feature is not included in the current version.

## Setup and Installation

1. Clone the Repository:
    - git clone https://github.com/aaviix/U-Watch.git
    - cd U-Watch

2. Open the Project in Xcode:
    - Open the .xcodeproj or .xcworkspace file.

3. Configure Capabilities for Each Target:

    - iPhone App:
        - Enable HealthKit and CoreLocation in the target’s Signing & Capabilities tab.
        - In the Info.plist, add the following keys:
            - NSHealthShareUsageDescription – e.g., "This app uses HealthKit data to display your health metrics."
            - NSHealthUpdateUsageDescription – e.g., "This app uses HealthKit data to display your health metrics."
            - NSLocationWhenInUseUsageDescription – e.g., "This app uses your location to enhance health tracking."
    - Apple Watch App:
        - Enable HealthKit and WatchKit in the target’s Signing & Capabilities tab.
        - In the Watch app’s Info.plist, add the HealthKit usage keys:
            - NSHealthShareUsageDescription
            - NSHealthUpdateUsageDescription

4. Build and Run:
    - Select the appropriate target (iPhone or Apple Watch) and run the app.
    
    - Note: HealthKit data is best tested on a real device with the appropriate data available.

## Usage

1. On the iPhone:

    - Navigate between tabs for the User Profile, Health Tracking, and Questionnaire pages.
    - Input your personal data and view your health metrics, which update via HealthKit queries.

2. On the Apple Watch:
    - Open the Health Tracking view on your watch.
    - View the various health metrics in a card-based UI that displays data such as heart rate, steps, sleep, calories, respiratory rate, activity energy, and body measurements.

## Known Issues

1. HealthKit Permissions:
    - Ensure all required Info.plist keys are correctly added to prevent crashes when requesting HealthKit authorization.

2. Simulator Limitations:
    - HealthKit data might not appear on the simulator; testing on a real device is recommended.

3. UIScene Configuration:
    - iOS apps require a UIScene configuration in Info.plist. WatchOS apps do not use UIScene in the same way. Any warnings regarding UIScene configuration can usually be ignored on WatchOS.