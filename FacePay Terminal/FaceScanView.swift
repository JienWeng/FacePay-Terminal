//
//  FaceScanView.swift
//  FacePay Terminal
//
//  Created by Lai Jien Weng on 02/08/2025.
//

import SwiftUI

struct FaceScanView: View {
    @ObservedObject var faceRecognition: FaceRecognitionService
    let amount: String
    let onScanComplete: (String) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                HStack {
                    Button(action: onCancel) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Cancel")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
                
                Text("FacePay Authentication")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Amount: RM \(formatAmount(amount))")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
            }
            
            // Face Scanning Area
            VStack(spacing: 20) {
                Text("Please look into the camera")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ZStack {
                    // Camera preview placeholder
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black)
                        .frame(width: 300, height: 400)
                    
                    // Face outline overlay
                    FaceOutlineView(
                        isScanning: faceRecognition.isScanning,
                        progress: faceRecognition.scanningProgress
                    )
                    
                    if !faceRecognition.isScanning && faceRecognition.detectedCustomerName == nil {
                        VStack(spacing: 15) {
                            Image(systemName: "faceid")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("Position your face in the frame")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                
                // Scanning Status
                if faceRecognition.isScanning {
                    VStack(spacing: 10) {
                        ProgressView(value: faceRecognition.scanningProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                            .frame(width: 250)
                        
                        Text("Scanning face... \(Int(faceRecognition.scanningProgress * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else if let customerName = faceRecognition.detectedCustomerName {
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            
                            Text("Face recognized!")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        
                        Text("Customer: \(customerName)")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Button(action: { onScanComplete(customerName) }) {
                            Text("Proceed with Payment")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        .frame(width: 250)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(15)
                }
            }
            
            Spacer()
            
            // Start Scan Button
            if !faceRecognition.isScanning && faceRecognition.detectedCustomerName == nil {
                Button(action: {
                    faceRecognition.startFaceScanning()
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Start Face Scan")
                            .fontWeight(.semibold)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
            
            // Security Notice
            VStack(spacing: 5) {
                HStack {
                    Image(systemName: "eye.slash")
                        .foregroundColor(.blue)
                    Text("Privacy Protected")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Text("Face data is processed locally and not stored")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
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

struct FaceOutlineView: View {
    let isScanning: Bool
    let progress: Double
    
    var body: some View {
        ZStack {
            // Face outline
            RoundedRectangle(cornerRadius: 120)
                .stroke(
                    isScanning ? Color.green : Color.white.opacity(0.7),
                    lineWidth: 3
                )
                .frame(width: 200, height: 240)
            
            // Scanning animation
            if isScanning {
                RoundedRectangle(cornerRadius: 120)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    .frame(width: 200, height: 240)
                    .scaleEffect(1 + progress * 0.1)
                    .opacity(1 - progress)
                
                // Scanning line
                Rectangle()
                    .fill(Color.green.opacity(0.7))
                    .frame(width: 180, height: 2)
                    .offset(y: -120 + (240 * progress))
            }
        }
    }
}
