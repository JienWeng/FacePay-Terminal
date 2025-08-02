//
//  ContentView.swift
//  FacePay Terminal
//
//  Created by Lai Jien Weng on 02/08/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var paymentService = PaymentService()
    @StateObject private var faceRecognitionService = FaceRecognitionService()
    
    @State private var currentView: AppView = .amountEntry
    @State private var enteredAmount: String = ""
    @State private var detectedCustomer: String = ""
    @State private var selectedPaymentMethod: TransactionType = .facePay
    
    enum AppView {
        case amountEntry
        case paymentMethod
        case faceScanning
        case cardPayment
        case processing
        case success
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.gray.opacity(0.02)
                    .ignoresSafeArea()
                
                // Main Content
                switch currentView {
                case .amountEntry:
                    AmountEntryView(
                        amount: $enteredAmount,
                        onContinue: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .paymentMethod
                            }
                        }
                    )
                    
                case .paymentMethod:
                    PaymentMethodView(
                        amount: enteredAmount,
                        onFacePaySelected: {
                            selectedPaymentMethod = .facePay
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .faceScanning
                            }
                        },
                        onCardPaymentSelected: {
                            selectedPaymentMethod = .cardPayment
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .cardPayment
                            }
                        },
                        onBackPressed: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .amountEntry
                            }
                        }
                    )
                    
                case .faceScanning:
                    FaceScanView(
                        faceRecognition: faceRecognitionService,
                        amount: enteredAmount,
                        onScanComplete: { customerName in
                            detectedCustomer = customerName
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .processing
                            }
                        },
                        onCancel: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .paymentMethod
                            }
                        }
                    )
                    
                case .cardPayment:
                    CardPaymentView(
                        amount: enteredAmount,
                        onPaymentComplete: { customerName in
                            detectedCustomer = customerName
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .processing
                            }
                        },
                        onCancel: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .paymentMethod
                            }
                        }
                    )
                    
                case .processing:
                    PaymentProcessingView(
                        paymentService: paymentService,
                        amount: enteredAmount,
                        customerName: detectedCustomer,
                        paymentMethod: selectedPaymentMethod,
                        onPaymentComplete: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .success
                            }
                        },
                        onPaymentFailed: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentView = .paymentMethod
                            }
                        }
                    )
                    
                case .success:
                    PaymentSuccessView(
                        amount: enteredAmount,
                        customerName: detectedCustomer,
                        paymentMethod: selectedPaymentMethod,
                        onNewTransaction: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                resetTransaction()
                            }
                        }
                    )
                }
            }
        }
        .preferredColorScheme(.light) // Force light mode for better yellow visibility
    }
    
    private func resetTransaction() {
        enteredAmount = ""
        detectedCustomer = ""
        selectedPaymentMethod = .facePay
        currentView = .amountEntry
        paymentService.resetPayment()
        faceRecognitionService.detectedCustomerName = nil
        faceRecognitionService.scanningProgress = 0.0
        faceRecognitionService.faceDetected = false
        faceRecognitionService.isScanning = false
    }
}

#Preview {
    ContentView()
}
