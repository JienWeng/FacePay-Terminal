//
//  CardPaymentView.swift
//  FacePay Terminal
//
//  Created by Lai Jien Weng on 02/08/2025.
//

import SwiftUI

struct CardPaymentView: View {
    let amount: String
    let onPaymentComplete: (String) -> Void
    let onCancel: () -> Void
    
    @State private var cardDetected = false
    @State private var processingPayment = false
    @State private var progress: Double = 0.0
    @State private var animationTimer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Button(action: onCancel) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Cancel")
                        }
                        .font(.headline)
                        .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                }
                
                VStack(spacing: 8) {
                    Text("Card Payment")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Amount: RM \(formatAmount(amount))")
                        .font(.title3)
                        .foregroundColor(.yellow)
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            Spacer()
            
            // Card Terminal Interface
            VStack(spacing: 30) {
                // Card Slot Animation
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black)
                        .frame(width: 280, height: 180)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.yellow, lineWidth: 2)
                        )
                    
                    VStack(spacing: 20) {
                        if !cardDetected && !processingPayment {
                            // Insert Card Animation
                            VStack(spacing: 12) {
                                Image(systemName: "creditcard")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text("Insert or Tap Card")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                // Animated card slot
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 120, height: 8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.yellow)
                                            .frame(width: 40, height: 8)
                                            .offset(x: -40)
                                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: UUID())
                                    )
                            }
                        } else if cardDetected && !processingPayment {
                            // Card Detected
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                                
                                Text("Card Detected")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Processing...")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        } else {
                            // Processing Payment
                            VStack(spacing: 12) {
                                CircularProgressView(progress: progress, color: .yellow)
                                    .frame(width: 60, height: 60)
                                
                                Text("Processing Payment")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("\(Int(progress * 100))%")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                }
                
                // Instructions
                VStack(spacing: 8) {
                    if !cardDetected && !processingPayment {
                        Text("Please insert your card or tap for contactless payment")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    } else if cardDetected && !processingPayment {
                        Text("Please wait while we process your payment")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Verifying transaction with your bank")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            Spacer()
            
            // Simulate Card Insert Button (for demo)
            if !cardDetected && !processingPayment {
                Button(action: simulateCardInsert) {
                    Text("Simulate Card Insert")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.yellow)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 20)
            }
            
            // Security Notice
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.shield")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                    
                    Text("Secure Transaction")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Text("Your card information is encrypted and secure")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .onDisappear {
            animationTimer?.invalidate()
        }
    }
    
    private func simulateCardInsert() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.5)) {
            cardDetected = true
        }
        
        // Start processing after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                processingPayment = true
            }
            
            // Simulate payment processing
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if progress < 1.0 {
                    progress += 0.05
                } else {
                    animationTimer?.invalidate()
                    // Simulate successful payment
                    onPaymentComplete("Card Holder")
                }
            }
        }
    }
    
    private func formatAmount(_ amount: String) -> String {
        if let doubleValue = Double(amount) {
            return String(format: "%.2f", doubleValue)
        }
        return amount
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 6)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.2), value: progress)
        }
    }
}
