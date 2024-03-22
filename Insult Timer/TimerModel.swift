

import Foundation
import AVFoundation

struct TimerModel {
    var selectedHours: Int = 0
    var selectedMinutes: Int = 0
    var selectedSeconds: Int = 0
    var totalSeconds: Int {
        return selectedHours * 3600 + selectedMinutes * 60 + selectedSeconds
    }
    
    func timeString(from totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}
