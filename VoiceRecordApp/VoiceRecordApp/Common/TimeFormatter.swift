//
//  TimeFormatter.swift
//  VoiceRecordApp
//
//  Created by 송규섭 on 10/22/25.
//

import Foundation

final class TimeFormatter {
    static let shared = TimeFormatter()
    
    private init() {}
    
    func formatTime(_ sec: TimeInterval) -> String {
        let min = Int(sec) / 60
        let sec = Int(sec) % 60
        return String(format: "%02d:%02d", min, sec)
    }
}
