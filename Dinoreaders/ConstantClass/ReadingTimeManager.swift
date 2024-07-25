import SwiftUI
import Combine

class ReadingTimeManager: ObservableObject {
    
    @Published var totalTimeSpent: TimeInterval = 0
    @Published var isTracking: Bool = false
    @Published var date: Date = Date()
    private var startTime: Date?
    private var timer: Timer?
    
    init() {
        
        // Load saved time from UserDefaults
        if let savedTime = UserDefaults.standard.value(forKey: "totalTimeSpent") as? TimeInterval {
            totalTimeSpent = savedTime
        }
        
        // Set up app lifecycle notifications
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // Start a timer to continuously update the total time
        // startTimer()
    }
    
    deinit {
        // Remove observers and invalidate timer
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
    }
    
    @objc private func appWillEnterForeground() {
        // Resume tracking when the app comes to the foreground
        if isTracking {
            startTime = Date()
        }
    }
    
    @objc private func appDidEnterBackground() {
        // Save the time spent when the app goes to the background
        if isTracking, let startTime = startTime {
            let timeSpent = Date().timeIntervalSince(startTime)
            totalTimeSpent += timeSpent
            self.startTime = nil // Reset start time to nil
            UserDefaults.standard.set(totalTimeSpent, forKey: "totalTimeSpent")
        }
    }
    
    func startTracking() {
        if !isTracking {
            isTracking = true
            startTime = Date()
            startTimer()
        }
    }
    
    func pauseTracking() {
        if isTracking {
            isTracking = false
            date = Date()
            if let startTime = startTime {
                let timeSpent = Date().timeIntervalSince(startTime)
                totalTimeSpent += timeSpent
                self.startTime = nil // Reset start time to nil
                UserDefaults.standard.set(totalTimeSpent, forKey: "totalTimeSpent")
            }
            timer?.invalidate()
        }
    }
    
    func resetTracking() {
        totalTimeSpent = 0
        startTime = nil
        date = Date()
        UserDefaults.standard.removeObject(forKey: "totalTimeSpent")
        timer?.invalidate()
        timer = nil
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
    }
    
    private func updateTime() {
        guard isTracking else { return }
        if let startTime = startTime {
            let timeSpent = Date().timeIntervalSince(startTime)
            totalTimeSpent += timeSpent
            self.startTime = Date() // Reset start time
        }
    }
}
