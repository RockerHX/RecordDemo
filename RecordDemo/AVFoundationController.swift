//
//  AVFoundationController.swift
//  RecordDemo
//
//  Created by RockerHX on 2018/7/4.
//  Copyright © 2018年 RockerHX. All rights reserved.
//


import UIKit
import AVFoundation


class AVFoundationController: UIViewController {

    @IBOutlet var label: UILabel?

    var session = AVAudioSession.sharedInstance()
    var record: AVAudioRecorder?
    var filePath: String?
    var fileURL: URL?
    var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        congifureAudio()
    }

    func congifureAudio() {
        session.requestRecordPermission { (pass) in
            print("requestRecordPermission: \(pass)")
        }
        let permission = session.recordPermission()
        switch permission {
        case .denied:
            return
        case .undetermined:
            session.requestRecordPermission { (pass) in
                print("requestRecordPermission: \(pass)")
            }
        default:
            break
        }

        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
        } catch {
            print(error)
            return
        }

        guard let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).last else { return }
        filePath = dir + "/RRecord.caf"
        fileURL = URL(fileURLWithPath: filePath!)
        let recordParms: [String: Any] = [AVSampleRateKey: 12000,
                                            AVFormatIDKey: Int(kAudioFormatLinearPCM),
                                   AVLinearPCMBitDepthKey: 16,
                                    AVNumberOfChannelsKey: 1,
                                 AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]

        do {
            record = try AVAudioRecorder(url: fileURL!, settings: recordParms)
            record?.isMeteringEnabled = true
            record?.prepareToRecord()
        } catch {
            print(error)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            self.stopRecord()
        }
    }

    func startRecord() {
        guard let isRecording = record?.isRecording else { return}
        if !isRecording {
            do {
                try session.setActive(true)
                record?.record()
                print("record!")
            } catch {
                print(error)
            }
        }
    }

    func stopRecord() {
        guard let isRecording = record?.isRecording else { return}
        if isRecording {
            record?.stop()
            do {
                try session.setActive(false)
                print("stop!!")
            } catch {
                print(error)
            }
        }

        let manager = FileManager.default
        guard let path = filePath else { return }
        if manager.fileExists(atPath: path) {
            guard let file = try? manager.attributesOfItem(atPath: path) else { return }
            print("\((file[.size] as? Double)! / 1000.0)")
        }
    }

    @IBAction func recordButtonTaped() {
        label?.text = "正在录音。。。"
        startRecord()
    }

    @IBAction func stopButtonTaped() {
        label?.text = "停止录音"
        stopRecord()
    }

    @IBAction func playButtonTaped() {
        label?.text = "播放录音。。。"

        guard let isRecording = record?.isRecording else { return}
        if !isRecording {
            do {
                try session.setCategory(AVAudioSessionCategoryPlayback)
                player = try AVAudioPlayer(contentsOf: fileURL!)
                player?.play()
            } catch {
                print(error)
            }
        }
    }

}

