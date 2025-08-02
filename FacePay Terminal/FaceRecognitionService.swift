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
import SwiftUI

class FaceRecognitionService: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var isScanning = false
    @Published var detectedCustomerName: String?
    @Published var scanningProgress: Double = 0.0
    @Published var faceDetected = false
    @Published var cameraPermissionGranted = false
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var faceDetectionRequest: VNDetectFaceRectanglesRequest?
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    // Mock customer database
    private let customerDatabase = [
        "customer001": "John Doe",
        "customer002": "Jane Smith",
        "customer003": "Michael Johnson",
        "customer004": "Sarah Wilson",
        "customer005": "David Brown"
    ]
    
    override init() {
        super.init()
        setupFaceDetection()
        checkCameraPermission()
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
        case .notDetermined:
            requestCameraPermission()
        default:
            cameraPermissionGranted = false
        }
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.cameraPermissionGranted = granted
            }
        }
    }
    
    func startFaceScanning() {
        guard cameraPermissionGranted else {
            requestCameraPermission()
            return
        }
        
        // Initialize camera first
        if captureSession == nil {
            setupCamera()
        }
        
        isScanning = true
        detectedCustomerName = nil
        scanningProgress = 0.0
        faceDetected = false
        
        // Start camera session
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }
    
    func stopFaceScanning() {
        isScanning = false
        faceDetected = false
        scanningProgress = 0.0
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.stopRunning()
        }
    }
    
    private func setupFaceDetection() {
        faceDetectionRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let results = request.results as? [VNFaceObservation] else { return }
            
            DispatchQueue.main.async {
                self?.handleFaceDetection(results: results)
            }
        }
        
        // Set low confidence threshold for easier detection
        faceDetectionRequest?.revision = VNDetectFaceRectanglesRequestRevision3
    }
    
    private func handleFaceDetection(results: [VNFaceObservation]) {
        if !results.isEmpty {
            let face = results.first!
            
            // Check if face confidence is above threshold (low threshold for demo)
            if face.confidence > 0.3 {
                if !faceDetected {
                    faceDetected = true
                    simulateFaceRecognition()
                }
            }
        } else {
            faceDetected = false
            scanningProgress = 0.0
        }
    }
    
    private func simulateFaceRecognition() {
        // Simulate face recognition progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            DispatchQueue.main.async {
                if self.faceDetected && self.isScanning {
                    self.scanningProgress += 0.08
                    
                    if self.scanningProgress >= 1.0 {
                        timer.invalidate()
                        // Simulate successful face recognition
                        self.detectedCustomerName = self.getRandomCustomerName()
                        self.isScanning = false
                    }
                } else {
                    timer.invalidate()
                    self.scanningProgress = 0.0
                }
            }
        }
    }
    
    private func getRandomCustomerName() -> String {
        return customerDatabase.randomElement()?.value ?? "Unknown Customer"
    }
    
    private func setupCamera() {
        // Don't setup if already exists
        if captureSession != nil { return }
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .medium
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("No back camera available")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Error creating video input: \(error)")
            return
        }
        
        captureSession?.beginConfiguration()
        
        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        }
        
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        
        if captureSession?.canAddOutput(videoDataOutput) == true {
            captureSession?.addOutput(videoDataOutput)
        }
        
        captureSession?.commitConfiguration()
        
        // Create preview layer immediately
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = .resizeAspectFill
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let faceDetectionRequest = faceDetectionRequest else { return }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        
        do {
            try imageRequestHandler.perform([faceDetectionRequest])
        } catch {
            print("Failed to perform face detection: \(error)")
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        // Setup camera if it doesn't exist yet
        if captureSession == nil {
            setupCamera()
        }
        
        return previewLayer
    }
}
