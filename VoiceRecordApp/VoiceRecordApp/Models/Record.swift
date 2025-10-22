//
//  Record.swift
//  VoiceRecordApp
//
//  Created by 송규섭 on 10/22/25.
//

import Foundation

struct Record: Codable, Identifiable {
    let identifier: UUID
    let duration: TimeInterval
    let title: String
    let fileName: String
    let date: Date
    var id: UUID { identifier }
}
