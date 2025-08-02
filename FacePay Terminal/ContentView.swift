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
    
    enum AppView {
        case amountEntry
        case paymentMethod
        case faceScanning
        case processing
        case success
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.gray.opacity(0.05)
                    .ignoresSafeArea()
                
                // Main Content
                switch currentView {
                case .amountEntry:
                    AmountEntryView(
                        amount: $enteredAmount,
                        onContinue: {
                            currentView = .paymentMethod
                        }
                    )
                    
                case .paymentMethod:
                    PaymentMethodView(
                        amount: enteredAmount,
                        onFacePaySelected: {
                            currentView = .faceScanning
                        },
                        onBackPressed: {
                            currentView = .amountEntry
                        }
                    )
                    
                case .faceScanning:
                    FaceScanView(
                        faceRecognition: faceRecognitionService,
                        amount: enteredAmount,
                        onScanComplete: { customerName in
                            detectedCustomer = customerName
                            currentView = .processing
                        },
                        onCancel: {
                            currentView = .paymentMethod
                        }
                    )
                    
                case .processing:
                    PaymentProcessingView(
                        paymentService: paymentService,
                        amount: enteredAmount,
                        customerName: detectedCustomer,
                        onPaymentComplete: {
                            currentView = .success
                        },
                        onPaymentFailed: {
                            currentView = .paymentMethod
                        }
                    )
                    
                case .success:
                    PaymentSuccessView(
                        amount: enteredAmount,
                        customerName: detectedCustomer,
                        onNewTransaction: {
                            resetTransaction()
                        }
                    )
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func resetTransaction() {
        enteredAmount = ""
        detectedCustomer = ""
        currentView = .amountEntry
        paymentService.resetPayment()
        faceRecognitionService.detectedCustomerName = nil
        faceRecognitionService.scanningProgress = 0.0
    }
}

#Preview {
    ContentView()
}
