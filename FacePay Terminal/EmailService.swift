//
//  EmailService.swift
//  FacePay Terminal
//
//  Created by Lai Jien Weng on 02/08/2025.
//

import Foundation
import MessageUI
import SwiftUI

class EmailService: NSObject, ObservableObject, MFMailComposeViewControllerDelegate {
    @Published var canSendEmail = false
    @Published var isShowingEmailComposer = false
    
    override init() {
        super.init()
        canSendEmail = MFMailComposeViewController.canSendMail()
    }
    
    func sendReceipt(receipt: Receipt, customerEmail: String = "customer@example.com") {
        guard canSendEmail else { return }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        // Email configuration
        mailComposer.setSubject("FacePay Transaction Receipt - \(receipt.transactionId)")
        mailComposer.setToRecipients([customerEmail])
        
        // Generate HTML receipt
        let htmlBody = generateReceiptHTML(receipt: receipt)
        mailComposer.setMessageBody(htmlBody, isHTML: true)
        
        // Present email composer
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(mailComposer, animated: true)
        }
    }
    
    func generateReceiptHTML(receipt: Receipt) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { text-align: center; background-color: #FFD700; padding: 20px; border-radius: 10px; }
                .content { padding: 20px; border: 1px solid #ddd; border-radius: 10px; margin-top: 20px; }
                .row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #eee; }
                .amount { font-size: 24px; font-weight: bold; color: #FFD700; }
                .footer { text-align: center; margin-top: 20px; color: #666; }
            </style>
        </head>
        <body>
            <div class="header">
                <h1>🏆 FacePay Terminal</h1>
                <h2>Transaction Receipt</h2>
            </div>
            
            <div class="content">
                <div class="row">
                    <span><strong>Transaction ID:</strong></span>
                    <span>\(receipt.transactionId)</span>
                </div>
                <div class="row">
                    <span><strong>Customer:</strong></span>
                    <span>\(receipt.customerName)</span>
                </div>
                <div class="row">
                    <span><strong>Payment Method:</strong></span>
                    <span>\(receipt.paymentMethod.rawValue)</span>
                </div>
                <div class="row">
                    <span><strong>Date & Time:</strong></span>
                    <span>\(formatter.string(from: receipt.timestamp))</span>
                </div>
                <div class="row">
                    <span><strong>Merchant:</strong></span>
                    <span>\(receipt.merchantName) (\(receipt.merchantId))</span>
                </div>
                <hr style="margin: 20px 0;">
                <div class="row">
                    <span><strong>Amount:</strong></span>
                    <span class="amount">RM \(String(format: "%.2f", receipt.amount))</span>
                </div>
                <div class="row">
                    <span><strong>Status:</strong></span>
                    <span style="color: green; font-weight: bold;">✅ COMPLETED</span>
                </div>
            </div>
            
            <div class="footer">
                <p>Thank you for using FacePay Terminal!</p>
                <p style="font-size: 12px;">This is an automated receipt. Please keep for your records.</p>
            </div>
        </body>
        </html>
        """
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

// SwiftUI wrapper for email composer
struct EmailComposerView: UIViewControllerRepresentable {
    let receipt: Receipt
    let customerEmail: String
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = context.coordinator
        
        mailComposer.setSubject("FacePay Transaction Receipt - \(receipt.transactionId)")
        mailComposer.setToRecipients([customerEmail])
        
        let emailService = EmailService()
        let htmlBody = emailService.generateReceiptHTML(receipt: receipt)
        mailComposer.setMessageBody(htmlBody, isHTML: true)
        
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: EmailComposerView
        
        init(_ parent: EmailComposerView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.isPresented = false
        }
    }
}