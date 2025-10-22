//
//  PlayerViewModel.swift
//  VoiceRecordApp
//
//  Created by 송규섭 on 10/22/25.
//

import SwiftUI
import AVFoundation

final class PlayerViewModel: NSObject, ObservableObject {
    // MARK: - Properties
    var trackFileName: String? {
        didSet { load() }
    }
    
    @Published private(set) var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published var isReverbEnabled: Bool = false
    @Published var processedFileURL: URL?
    @Published var isProcessing: Bool = false
    
    private var engine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var reverbNode = AVAudioUnitReverb()
    private var timer: Timer?
    private var file: AVAudioFile?
    private var audioBuffer: AVAudioPCMBuffer?
    
    override init() {
        super.init()
        setupEngine()
    }
    
    private func setupEngine() {
        let fileFormat = file?.processingFormat
        engine.attach(playerNode)
        engine.attach(reverbNode)
        engine.connect(playerNode, to: reverbNode, format: fileFormat)
        engine.connect(reverbNode, to: engine.mainMixerNode, format: fileFormat)
        reverbNode.loadFactoryPreset(.mediumHall)
        reverbNode.wetDryMix = 0
    }
    
    func load() {
        stop()
        guard let fileName = trackFileName else { return }
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(fileName)
        do {
            file = try AVAudioFile(forReading: url)
            if let file {
                engine.stop()
                engine.reset()
                engine.detach(playerNode)
                engine.detach(reverbNode)
                
                audioBuffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
                try file.read(into: audioBuffer!)
                
                engine.attach(playerNode)
                engine.attach(reverbNode)
                engine.connect(playerNode, to: reverbNode, format: file.processingFormat)
                engine.connect(reverbNode, to: engine.mainMixerNode, format: file.processingFormat)
                reverbNode.loadFactoryPreset(.largeHall)
                reverbNode.wetDryMix = isReverbEnabled ? 25 : 0
                
                let sampleRate = file.processingFormat.sampleRate
                let length = file.length
                duration = Double(length) / sampleRate
                currentTime = 0
            }
            isPlaying = false
        } catch {
            print("Failed to load audio: \(error)")
        }
    }
    
    func play() {
        guard let buffer = audioBuffer else { return }
        try? engine.start()
        playerNode.stop()
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        playerNode.play()
        isPlaying = true
        startTimer()
    }
    
    func pause() {
        playerNode.pause()
        isPlaying = false
        stopTimer()
    }
    
    func stop() {
        playerNode.stop()
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
    
    func toggleReverb(_ enabled: Bool) {
        reverbNode.wetDryMix = enabled ? 50 : 0
        isReverbEnabled = enabled
        renderReverbAudioToFile()
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            self.currentTime = self.playerNode.lastRenderTime.flatMap {
                self.playerNode.playerTime(forNodeTime: $0)?.sampleTime
            }.map { Double($0) / self.file!.processingFormat.sampleRate } ?? 0
        })
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Share 기능
    func renderReverbAudioToFile() {
        guard let file else { return }
        let outputFileName = "processed_" + (trackFileName ?? "UUID().uuidString.m4a")
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documents.appendingPathComponent(outputFileName)
        
        guard let format = file.processingFormat as AVAudioFormat?,
              let audioFile = try? AVAudioFile(forReading: file.url) else { return }
        
        let outputSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: format.sampleRate,
            AVNumberOfChannelsKey: format.channelCount,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        guard let outputFile = try? AVAudioFile(forWriting: outputURL, settings: outputSettings) else { return }
        
        let engine = AVAudioEngine()
        let playerNode = AVAudioPlayerNode()
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.smallRoom)
        reverbNode.wetDryMix = isReverbEnabled ? 20 : 0
        
        engine.attach(playerNode)
        engine.attach(reverbNode)
        engine.connect(playerNode, to: reverbNode, format: format)
        engine.connect(reverbNode, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: 4096)
        } catch {
            print("Rendering mode error: \(error)")
            return
        }
        
        try? engine.start()
        playerNode.scheduleFile(audioFile, at: nil)
        playerNode.play()
        
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 4096)!
        while engine.manualRenderingSampleTime < audioFile.length {
            let frameCount = min(4096, audioFile.length - engine.manualRenderingSampleTime)
            let status = try? engine.renderOffline(AVAudioFrameCount(frameCount), to: buffer)
            if status == .success {
                try? outputFile.write(from: buffer)
            }
        }
        
        playerNode.stop()
        engine.stop()
        
        let size = (try? FileManager.default.attributesOfItem(atPath: outputURL.path)[.size]) as? UInt64 ?? 0
        print("processed file size:", size)
        
        DispatchQueue.main.async {
            self.processedFileURL = outputURL
        }
        
    }
    
    func getOriginalFileURL() -> URL? {
        guard let fileName = trackFileName else { return nil }
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(fileName)
    }
}
