//
//  RecordingViewModel.swift
//  VoiceRecordApp
//
//  Created by 송규섭 on 10/21/25.
//

import Foundation
import AVFoundation

final class RecordingViewModel: NSObject, ObservableObject {
    @Published var recordingTime: String = "00:00"
    @Published var records: [Record] = []
    @Published var isRecording = false
    private var timer: Timer?
    private var audioRecorder: AVAudioRecorder?
    private var currentFileURL: URL?
    private var currentFileName: String?
    
    override init() {
        super.init()
        loadRecords()
    }
    
    func handleRecordingEvent() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
        isRecording.toggle()
    }
    
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = UUID().uuidString + ".m4a"
            let fileURL = documents.appendingPathComponent(fileName)
            currentFileURL = fileURL
            currentFileName = fileName
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [weak self] _ in
                guard let self else { return }
                let time = self.audioRecorder?.currentTime ?? 0
                DispatchQueue.main.async {
                    self.recordingTime = TimeFormatter.shared.formatTime(time)
                }
            })
        } catch {
            print("Record Error: \(error)")
        }
    }
    
    func stopRecording() {
        timer?.invalidate()
        timer = nil
        audioRecorder?.stop()
        recordingTime = "00:00"
    }
    
    func saveTitleAndRecord(title: String) async {
        guard let url = currentFileURL, let fileName = currentFileName else { return }
        let asset = AVURLAsset(url: url)
        let duration = (try? await asset.load(.duration).seconds) ?? 0
        let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
        let creationDate = attrs?[.creationDate] as? Date ?? Date()
        let title = title == "" ? "Untitled" : title
        let record = Record(identifier: UUID(), duration: duration, title: title, fileName: fileName, date: creationDate)
        await MainActor.run {
            self.records.append(record)
        }
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: "Records")
        }
        currentFileURL = nil
        currentFileName = nil
    }
    
    /// 앱 디렉토리 내 .m4a 확장자 파일들의 URL들을 가져옵니다.
    func loadRecords() {
        var availableRecords: [Record] = []
        if let savedData = UserDefaults.standard.data(forKey: "Records"),
           let loadedRecords = try? JSONDecoder().decode([Record].self, from: savedData) {
            
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            for record in loadedRecords {
                let url = documents.appendingPathComponent(record.fileName)
                if FileManager.default.fileExists(atPath: url.path) {
                    availableRecords.append(record)
                } else {
                    print("파일이 존재하지 않는 record 무시됨: \(record.fileName)")
                }
            }
        }
        DispatchQueue.main.async {
            self.records = availableRecords
            print("저장되어 있는 records 수: \(self.records.count)")
        }
    }
}

extension RecordingViewModel: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        audioRecorder = nil
    }
}
