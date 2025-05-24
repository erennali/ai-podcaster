//
//  AVSpeechService.swift
//  AI Podcaster
//
//  Created by Eren Ali Koca on 29.04.2025.
//

import Foundation
import AVKit
import AVFoundation
import UIKit
import MediaPlayer

class AVSpeechService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    static let shared = AVSpeechService()
    var synthesizer: AVSpeechSynthesizer
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var currentText: String = ""
    private var currentPosition: Int = 0
    private var remotePause = false
    
    override init() {
        synthesizer = AVSpeechSynthesizer()
        super.init()
        synthesizer.delegate = self
        setupAudioSession()
        setupRemoteCommandCenter()
        configureNowPlaying(title: "AI Podcaster", artist: "Playing podcast")
    }
    
    private func setupAudioSession() {
        do {
            // Arka planda ses çalması için .playback kategorisine geçelim
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.duckOthers, .allowBluetooth, .allowAirPlay]
            )
            
            // Ses kesintilerinde davranışı ayarlayalım
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            // Uzaktan kontrolü destekleyelim
            UIApplication.shared.beginReceivingRemoteControlEvents()
            
            // Ses kesintilerinde otomatik ses oturumu yönetimi
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAudioSessionInterruption),
                name: AVAudioSession.interruptionNotification,
                object: nil
            )
            
            // Rota değişikliklerini takip edelim (örn. kulaklık takıldığında)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleRouteChange),
                name: AVAudioSession.routeChangeNotification,
                object: nil
            )
        } catch {
            print("Audio session setup error: \(error.localizedDescription)")
        }
    }
    
    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        if type == .began {
            // Kesinti başladı, ses duraklatılmalı
            if synthesizer.isSpeaking {
                remotePause = true
                pause()
            }
        } else if type == .ended {
            // Kesinti bitti, tekrar başlatılabilir
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            
            if options.contains(.shouldResume) && remotePause {
                // Ses otomatik olarak devam etmeli
                resume()
                remotePause = false
            }
        }
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        // Kulaklık çıkarıldığında
        if reason == .oldDeviceUnavailable {
            if synthesizer.isSpeaking {
                pause()
            }
        }
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play, pause ve stop komut tanımları
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.synthesizer.isPaused {
                self.resume()
                return .success
            } else if !self.synthesizer.isSpeaking {
                if !self.currentText.isEmpty {
                    self.speak(text: self.currentText)
                    return .success
                }
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.synthesizer.isSpeaking {
                self.pause()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.stopCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            self.stop()
            return .success
        }
    }
    
    private func configureNowPlaying(title: String, artist: String) {
        // NowPlaying bilgilerini ayarla (control center'da görünecek)
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        
        if let image = UIImage(named: "MyAppIcon") {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in return image }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func speak(text: String, title: String = "AI Podcaster") {
        // Mevcut metni kaydet
        self.currentText = text
        self.currentPosition = 0
        
        // NowPlaying ve Kontrol Merkezi için bilgileri ayarla
        configureNowPlaying(title: title, artist: "AI Podcaster")
        
        // Önce arka plan görevini başlat
        startBackgroundTask()
        
        // Devam eden herhangi bir sesi durdur
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Ses oturumunu yeniden etkinleştir
        activateAudioSession()
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.volume = 1
        utterance.voice = AVSpeechSynthesisVoice(language: "tr-TR")
        
        // AVAudioSession'ı yeniden etkinleştir
        synthesizer.speak(utterance)
        
        // Kilit ekranda ve Control Center'da görünecek olan bilgileri güncelle
        updateNowPlayingInfo(isPlaying: true)
    }
    
    // Ses oturumunu aktifleştiren yardımcı metod
    private func activateAudioSession() {
        do {
            // Ses oturumunu etkinleştirmeden önce kategoriyi yeniden kontrol edelim
            let audioSession = AVAudioSession.sharedInstance()
            if audioSession.category != .playback {
                try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers, .allowBluetooth, .allowAirPlay])
            }
            
            if !audioSession.isOtherAudioPlaying {
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            }
        } catch {
            print("Failed to activate audio session: \(error.localizedDescription)")
        }
    }
    
    func pause() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .immediate)
            updateNowPlayingInfo(isPlaying: false)
        }
    }
    
    func resume() {
        if synthesizer.isPaused {
            // Arka plan izni yenile
            startBackgroundTask()
            synthesizer.continueSpeaking()
            updateNowPlayingInfo(isPlaying: true)
        }
    }
    
    func stop() {
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
            updateNowPlayingInfo(isPlaying: false)
            endBackgroundTask()
        }
    }
    
    // Kilit ekran ve Control Center bilgilerini güncelle
    private func updateNowPlayingInfo(isPlaying: Bool) {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // Arka plan görevi yönetimi
    private func startBackgroundTask() {
        // Önceki varsa sonlandır
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
        
        // Yeni bir arka plan görevi başlat
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            // Arka plan süresi dolduğunda çalışacak kod
            print("Background task expired")
            self?.endBackgroundTask()
        }
        
        if backgroundTask == .invalid {
            print("Failed to start background task")
        } else {
            print("Background task started with identifier: \(backgroundTask)")
        }
    }
    
    private func endBackgroundTask() {
        // Sadece geçerli bir görev varsa sonlandır
        if backgroundTask != .invalid {
            print("Ending background task: \(backgroundTask)")
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // Konuşma bittiğinde arka plan görevini sonlandır
        endBackgroundTask()
        updateNowPlayingInfo(isPlaying: false)
        
        // Post notification when speech finishes
        NotificationCenter.default.post(name: NSNotification.Name("AVSpeechSynthesizerDidFinishSpeechUtterance"), object: nil)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("Speech started")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("Speech paused")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("Speech resumed")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("Speech cancelled")
        
        // Konuşma iptal edildiğinde arka plan görevini sonlandır
        endBackgroundTask()
        updateNowPlayingInfo(isPlaying: false)
        
        // Post notification when speech is cancelled
        NotificationCenter.default.post(name: NSNotification.Name("AVSpeechSynthesizerDidFinishSpeechUtterance"), object: nil)
    }
}
