//
//  FaceRecognitionService.swift
//  FacePay Terminal
//
//  Created by Lai Jien Weng on 02/08/2025.
//

import Foundation
import Vision
import AVFoundation
import UIKit

class FaceRecognitionService: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var detectedCustomerName: String?
    @Published var scanningProgress: Double = 0.0
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    func startFaceScanning() {
        isScanning = true
        detectedCustomerName = nil
        scanningProgress = 0.0
        
        // Simulate face scanning process
        simulateFaceScanning()
    }
    
    func stopFaceScanning() {
        isScanning = false
        captureSession?.stopRunning()
    }
    
    private func simulateFaceScanning() {
        // Simulate scanning progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            DispatchQueue.main.async {
                self.scanningProgress += 0.05
                
                if self.scanningProgress >= 1.0 {
                    timer.invalidate()
                    // Simulate successful face recognition
                    self.detectedCustomerName = self.getRandomCustomerName()
                    self.isScanning = false
                }
            }
        }
    }
    
    private func getRandomCustomerName() -> String {
        let names = ["John Doe", "Jane Smith", "Michael Johnson", "Sarah Wilson", "David Brown", "Emily Davis"]
        return names.randomElement() ?? "Unknown Customer"
    }
    
    // MARK: - Real Implementation (for future use)
    func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession?.canAddOutput(metadataOutput) == true {
            captureSession?.addOutput(metadataOutput)
        } else {
            return
        }
    }
}
