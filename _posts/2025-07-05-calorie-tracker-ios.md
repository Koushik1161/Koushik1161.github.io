---
layout: post
title: "Starting an iOS Project: CalorieTracker Foundation"
subtitle: "Setting up a SwiftUI project with proper testing infrastructure from day one"
date: 2025-07-05
---

There's a particular satisfaction in setting up a new project correctly. Not writing features yet—just getting the foundation right so that when you do write features, everything works smoothly. CalorieTracker is that kind of project: a clean iOS starting point ready for development.

## The Modern SwiftUI Stack

The project uses Swift and SwiftUI, Apple's declarative UI framework. The entry point is straightforward:

```swift
@main
struct CalorieTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

No AppDelegate, no storyboards, no UIKit cruft. Modern SwiftUI is remarkably clean. The entire app definition fits in a few lines.

## Testing Infrastructure from Day One

The project includes three test targets: unit tests, UI tests, and launch performance tests. None have actual test logic yet—they're scaffolding for future development.

Why set up testing before you have anything to test? Because retrofitting tests is painful. You end up with tightly coupled code that's hard to test, or you spend significant effort refactoring for testability.

Starting with test infrastructure means you naturally write testable code. The friction of "I should write a test but I haven't set up testing yet" disappears.

## The Launch Test Pattern

One test file deserves mention: `CalorieTrackerUITestsLaunchTests.swift`. It includes screenshot attachment capability for launch performance:

```swift
let attachment = XCTAttachment(screenshot: app.screenshot())
attachment.name = "Launch Screen"
attachment.lifetime = .keepAlways
add(attachment)
```

This captures the launch screen and attaches it to test results. When you're optimizing launch performance, having visual records of each launch is valuable for spotting regressions.

## What's Not Here Yet

The actual calorie tracking functionality is entirely missing. No data models for food or meals. No persistence layer. No calorie database or API integration. No visualization of dietary goals.

The ContentView shows a globe icon and "Hello, world!"—the default Xcode template. It's a blank canvas.

This is intentional. The project represents the moment before implementation begins, when the infrastructure is ready but the features aren't. It's a snapshot of proper project setup.

## The Asset Configuration

The project includes a universal app icon asset configured for light, dark, and tinted appearances. This seems like a small detail, but iOS 18+ uses these variants in different contexts. Setting them up correctly now avoids jarring appearance when your app is featured on the home screen.

The AccentColor asset defines a consistent tint across the app. SwiftUI uses this automatically for interactive elements. Define it once, and buttons, links, and toggles all coordinate.

## No External Dependencies

There's no CocoaPods file, no Package.swift, no third-party frameworks. Everything uses Apple's native frameworks: SwiftUI for UI, Testing for unit tests, XCTest for UI tests.

For many apps, this is sufficient. The Apple ecosystem provides most of what you need: networking, persistence, authentication, push notifications. Adding dependencies introduces upgrade burdens, potential conflicts, and expanded attack surface.

Start minimal. Add dependencies when you genuinely need them, not speculatively.

## The Path Forward

If I were continuing this project, the next steps would be:

1. Define a `Meal` model with food items and calorie counts
2. Add a `MealListView` with swipe-to-delete and add functionality
3. Implement persistence with SwiftData or Core Data
4. Create daily summary and goal tracking views
5. Add a food database—possibly USDA's API for nutritional data

Each step would come with tests. The infrastructure is ready; the implementation awaits.

## The Value of Foundations

This might seem like a trivial project to write about. It's literally the Xcode template with no changes. But I've seen too many projects start with features first and infrastructure never. Tests get added reluctantly, months later, to code that was never designed for testability.

CalorieTracker is a reminder that setup matters. A few hours invested in project structure pays dividends across the entire development lifecycle. The foundation isn't the exciting part, but it makes the exciting parts possible.
