//
//  PlayerViewModel.swift
//  VoiceRecordApp
//
//  Created by 송규섭 on 10/22/25.
//

import SwiftUI
import AVFoundation

final class PlayerViewModel: NSObject, ObservableObject {
    var trackFileName: String? {
        didSet { load() }
    }
    @Published private(set) var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    func load() {
        stop()
        guard let fileName = trackFileName else { return }
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(fileName)
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            } else {
                print("오디오 파일이 경로에 없습니다: \(url.path)")
            }
            duration = audioPlayer?.duration ?? 0
            currentTime = 0
            isPlaying = false
        } catch {
            print("Failed to load audio: \(error)")
        }
    }
    
    func play() {
        guard let player = audioPlayer else { return }
        player.delegate = self
        player.play()
        isPlaying = true
        startTimer()
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func stop() {
        audioPlayer?.stop()
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [weak self] _ in
            guard let self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
        })
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func seekTo(time: TimeInterval) {
        audioPlayer?.currentTime = time
    }
}

extension PlayerViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentTime = 0
            self.stopTimer()
        }
    }
}
