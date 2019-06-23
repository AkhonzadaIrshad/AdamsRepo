//
//  AudioRecorderManager.swift
//  rzq
//
//  Created by Zaid najjar on 4/4/19.
//  Copyright © 2019 technzone. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorderManager: NSObject {
    
    static let shared = AudioRecorderManager()
    
    var recordingSession: AVAudioSession!
    var recorder:AVAudioRecorder?
    
    func setup() {
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission() {(allowed: Bool) -> Void  in
                
                if allowed {
                    print("Recording Allowed")
                    
                } else {
                    print("Recording Allowed Faild")
                    
                }
                
            }
            
            
        } catch {
            print("Faild to setCategory",error.localizedDescription)
        }
        
        guard self.recordingSession != nil else {
            print("Error session is nil")
            return
        }
        
        
    }
    
    var meterTimer:Timer?
    func recored(path:URL,result:(_ isRecording:Bool)->Void) {
        
        let audioURL = NSURL(fileURLWithPath: path.path)
        
        
        //        let recoredSt:[String:AnyObject] = [
        //            AVFormatIDKey:NSNumber(value: kAudioFormatMPEG4AAC),
        //            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
        //            AVEncoderBitRateKey : 12000,
        //            AVNumberOfChannelsKey: 2
        //        ]
        
        let recordSettings: [String: AnyObject] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0 as AnyObject,
            AVNumberOfChannelsKey: 1 as AnyObject,
            ]
        
        do {
            recorder = try AVAudioRecorder(url: audioURL as URL, settings: recordSettings)
            recorder?.delegate = self
            
            recorder?.isMeteringEnabled = true
            recorder?.prepareToRecord()
            
            recorder?.record()
            
            
            self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                   target:self,
                                                   selector:#selector(AudioRecorderManager.updateAudioMeter(timer:)),
                                                   userInfo:nil,
                                                   repeats:true)
            result(true)
            print("Recording")
        } catch {
            result(false)
        }
    }
    
    var recorderTime: String?
    var recorderApc0: Float?
    var recorderPeak0:Float?
    
    @objc func updateAudioMeter(timer:Timer){
        
        if let recorder = recorder {
            
            let dFormat = "%02d"
            let min:Int = Int(recorder.currentTime / 60)
            let sec:Int = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60.0))
            
            recorderTime  = "\(String(format: dFormat, min)):\(String(format: dFormat, sec))"
            
            recorder.updateMeters()
            recorderApc0 = recorder.averagePower(forChannel: 0)
            recorderPeak0 = recorder.peakPower(forChannel: 0)
            
            
        }
    }
    
    func finishRecording(){
        
        self.recorder?.stop()
        self.meterTimer?.invalidate()
    }
}

extension AudioRecorderManager:AVAudioRecorderDelegate {
    
    // Audio Recorder Delegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        print("Audio Recorder did finish",flag)
    }
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder,
                                          error: Error?) {
        print("\(error?.localizedDescription ?? "")")
    }
    
}






