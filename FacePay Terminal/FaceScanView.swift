//
//  FaceScanView.swift
//  FacePay Terminal
//
//  Created by Lai Jien Weng on 02/08/2025.
//

import SwiftUI
import AVFoundation

struct FaceScanView: View {
    @ObservedObject var faceRecognition: FaceRecognitionService
    let amount: String
    let onScanComplete: (String) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            // Full screen camera view
            CameraPreviewView(faceRecognition: faceRecognition)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Top controls
                HStack {
                    Button(action: onCancel) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    Text("RM \(formatAmount(amount))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Bottom status
                VStack(spacing: 20) {
                    if faceRecognition.isScanning {
                        VStack(spacing: 12) {
                            CircularProgressView(progress: faceRecognition.scanningProgress, color: .yellow)
                                .frame(width: 60, height: 60)
                            
                            Text("Scanning...")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(20)
                        }
                    } else if let customerName = faceRecognition.detectedCustomerName {
                        VStack(spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                                
                                Text("Face Recognized!")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding(12)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(20)
                            
                            Text("\(customerName)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(20)
                            
                            Button(action: { onScanComplete(customerName) }) {
                                Text("Continue")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.yellow)
                                    .cornerRadius(25)
                            }
                            .padding(.horizontal, 40)
                        }
                    } else if faceRecognition.faceDetected && !faceRecognition.isScanning {
                        Button(action: {
                            faceRecognition.startFaceScanning()
                        }) {
                            Text("Scan Face")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.yellow)
                                .cornerRadius(25)
                        }
                        .padding(.horizontal, 40)
                    } else if !faceRecognition.cameraPermissionGranted {
                        Button(action: {
                            faceRecognition.requestCameraPermission()
                        }) {
                            Text("Allow Camera")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.yellow)
                                .cornerRadius(25)
                        }
                        .padding(.horizontal, 40)
                    }
                }
                .padding(.bottom, 50)
            }
            
            // Face detection indicator
            if faceRecognition.faceDetected {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.yellow, lineWidth: 4)
                    .frame(width: 250, height: 300)
                    .animation(.easeInOut(duration: 0.5), value: faceRecognition.faceDetected)
            }
        }
        .onAppear {
            // Setup camera permissions and initialize camera first
            faceRecognition.requestCameraPermission()
            
            // Small delay to ensure camera permission is processed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                faceRecognition.startFaceScanning()
            }
        }
        .onDisappear {
            faceRecognition.stopFaceScanning()
        }
    }
    
    private func formatAmount(_ amount: String) -> String {
        if let doubleValue = Double(amount) {
            return String(format: "%.2f", doubleValue)
        }
        return amount
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let faceRecognition: FaceRecognitionService
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear // Remove black background
        
        // Add the preview layer immediately if available
        if let previewLayer = faceRecognition.getPreviewLayer() {
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Ensure preview layer is properly set up and sized
        if let previewLayer = faceRecognition.getPreviewLayer() {
            if previewLayer.superlayer == nil {
                uiView.layer.addSublayer(previewLayer)
            }
            previewLayer.frame = uiView.bounds
            previewLayer.videoGravity = .resizeAspectFill
        }
    }
}
