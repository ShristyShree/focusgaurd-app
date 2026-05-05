# FocusGuard – Smart Focus Monitoring App

FocusGuard is a mobile application designed to help users stay focused during study or work sessions. The app monitors user activity during a session and prompts for interaction at regular intervals to detect loss of focus.

This project is part of my growing interest in mobile app development, with a focus on building applications that can be adapted for the Apple ecosystem using iOS technologies such as Swift, SwiftUI, and Xcode for future App Store deployment.

## Overview

The app allows users to start a timed focus session and tracks their engagement throughout. If the user does not respond to periodic focus check prompts, the app treats it as inactivity and records it as a distraction.

## Features

- Start focus sessions with selectable durations (15, 25, 45 minutes)
- Countdown timer displayed during the session
- Periodic focus check prompts asking the user to confirm attention
- If the prompt is not responded to within a few seconds, the app records it as a missed interaction
- Alerts are shown when inactivity is detected
- Tracks total session time, number of distractions, and basic focus score
- Summary screen at the end of each session with performance feedback
- Clean and minimal user interface inspired by modern iOS design patterns

## Tech Stack

- Flutter (cross-platform app development)
- Dart

## Structure

- Home Screen: session setup and duration selection  
- Session Screen: timer, focus tracking, and interaction checks  
- Summary Screen: session results and feedback  

## Future Improvements

- Rebuilding the application using Swift and SwiftUI in Xcode for native iOS development  
- Publishing the app on the Apple App Store  
- Camera-based detection for real-time drowsiness analysis  
- Notification-based reminders when focus drops  

## Note

This project focuses on simulating a focus monitoring system using user interaction patterns rather than implementing full machine learning-based drowsiness detection. It also serves as a foundation for transitioning into iOS app development using SwiftUI and the Apple development ecosystem.