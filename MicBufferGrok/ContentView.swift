//
//  ContentView.swift
//  MicBufferGrok
//
//  Created by laptop on 5/15/22.
//

import AVFoundation
import SwiftUI

class AudioBufferDelegate: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
  func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
    print("Got a sample buffer")
    let block = CMSampleBufferGetDataBuffer(sampleBuffer)
    var length = 0
    var data: UnsafeMutablePointer<Int8>?
    let status = CMBlockBufferGetDataPointer(block!, atOffset: 0, lengthAtOffsetOut: nil, totalLengthOut: &length, dataPointerOut: &data) // TODO: check for errors
    let result = NSData(bytes: data, length: length)
  }
}

struct ContentView: View {
  var session: AVCaptureSession
  var audioEngine: AVAudioEngine
//  var inputNode: AVAudioInputNode?

  init() {
    session = AVCaptureSession()
    audioEngine = AVAudioEngine()
  }

  var body: some View {
    Text("Hello, world!")
      .padding()
      .onAppear {
        requestMicrophonePermissions()
      }
  }

  func requestMicrophonePermissions() {
    let status = AVCaptureDevice.authorizationStatus(for: .audio)
    switch status {
    case .authorized:
      print("Authorized")
      setupMicrophone()
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .audio) { granted in
        if granted {
          print("Authorized")
          setupMicrophone()
        } else {
          print("Not authorized")
        }
      }
    case .denied:
      print("Denied")
    case .restricted:
      print("Restricted")
    @unknown default:
      print("Unknown error")
    }
  }

  func setupMicrophone() {
    let audioSession = AVAudioSession.sharedInstance()
//    do {
    try! audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
    try! audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//    } catch {
//      subscriber.send(completion: .failure(.couldntConfigureAudioSession))
//      return cancellable
//    }
    let inputNode = audioEngine.inputNode
    var count = 0
    inputNode.installTap(
      onBus: 0,
      bufferSize: 1024,
      format: inputNode.outputFormat(forBus: 0)
    ) { a, b in
      print("buffer")
      count = count + 1
      print(count)
      print(a)
      print(b)
//      request.append(buffer)
    }
    audioEngine.prepare()
    try! audioEngine.start()
  }

  func _setupMicrophone() {
    let audioDevice = AVCaptureDevice.default(for: .audio)

    session.sessionPreset = AVCaptureSession.Preset.medium

    let mic = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .unspecified)

    let audio_output = AVCaptureAudioDataOutput()
    let delegate = AudioBufferDelegate()
    audio_output.setSampleBufferDelegate(delegate, queue: DispatchQueue.main)

    let mic_input = try! AVCaptureDeviceInput(device: mic!)

    session.addInput(mic_input)
    session.addOutput(audio_output)

    session.startRunning()
  }

  func captureOutput(captureOutput _: AVCaptureOutput!, didOutputSampleBuffer _: CMSampleBuffer!, fromConnection _: AVCaptureConnection!)
  {
    // Do something here
  }
}
