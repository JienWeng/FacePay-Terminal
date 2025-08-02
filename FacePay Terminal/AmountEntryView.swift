//
//  AmountEntryView.swift
//  FacePay Terminal
//
//  Created by Lai Jien Weng on 02/08/2025.
//

import SwiftUI

struct AmountEntryView: View {
    @Binding var amount: String
    let onContinue: () -> Void
    
    private let keypadButtons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("FacePay Terminal")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Enter Payment Amount")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // Amount Display
            VStack(spacing: 15) {
                Text("Amount (MYR)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("RM")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text(formatAmount(amount))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                        .frame(minWidth: 200, alignment: .trailing)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Keypad
            VStack(spacing: 15) {
                ForEach(keypadButtons, id: \.self) { row in
                    HStack(spacing: 15) {
                        ForEach(row, id: \.self) { button in
                            KeypadButton(
                                text: button,
                                action: { handleKeypadInput(button) }
                            )
                        }
                    }
                }
            }
            
            Spacer()
            
            // Continue Button
            Button(action: onContinue) {
                HStack {
                    Text("Continue")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    isValidAmount() ? Color.blue : Color.gray
                )
                .cornerRadius(12)
            }
            .disabled(!isValidAmount())
        }
        .padding()
    }
    
    private func handleKeypadInput(_ input: String) {
        switch input {
        case "⌫":
            if !amount.isEmpty {
                amount.removeLast()
            }
        case ".":
            if !amount.contains(".") && !amount.isEmpty {
                amount += input
            }
        default:
            // Limit to 2 decimal places
            if amount.contains(".") {
                let components = amount.split(separator: ".")
                if components.count > 1 && components[1].count >= 2 {
                    return
                }
            }
            
            // Limit total length
            if amount.count < 10 {
                amount += input
            }
        }
    }
    
    private func formatAmount(_ amount: String) -> String {
        if amount.isEmpty {
            return "0.00"
        }
        
        if let doubleValue = Double(amount) {
            return String(format: "%.2f", doubleValue)
        }
        
        return amount
    }
    
    private func isValidAmount() -> Bool {
        guard let doubleValue = Double(amount) else { return false }
        return doubleValue > 0 && doubleValue <= 99999.99
    }
}

struct KeypadButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(width: 80, height: 80)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(40)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: text)
    }
}
