import Foundation
import PlaygroundSupport

let now = Date()
print(now)

let future = now.addingTimeInterval(24.0 * 3600.0)

let interval = DateInterval(start: now, end: future)
print(interval)

let intervalSeconds = future.timeIntervalSinceNow
print("intervalSeconds=",intervalSeconds)
