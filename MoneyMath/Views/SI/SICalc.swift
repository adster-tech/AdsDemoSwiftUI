import SwiftUI

struct SICalcView: View {
    @State private var interest = ""
    @State private var time = ""
    @State private var principal = ""
    @State private var result = "₹0.00"
    @State private var isCompound = false
    @State private var history: [String] = []
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    content
                    historySection
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Interest Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                to: nil, from: nil, for: nil)
            }
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fill in the amount, interest rate, and time to quickly calculate your interest.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 12)
            
            Text("Principal Amount")
            TextField("0.00", text: $principal)
                .modifier(TextInputModifier())
            
            Text("Rate (%)")
            TextField("1", text: $interest)
                .modifier(TextInputModifier())
            
            Text("Time (years)")
            TextField("1", text: $time)
                .modifier(TextInputModifier())
            
            Toggle("Use Compound Interest", isOn: $isCompound)
                .tint(.blue) 
                .padding(.vertical, 8)
            
            HStack(spacing: 12) {
                getButton("Calculate", action: calculate)
                getButton("Reset", action: reset)
            }
            
            HStack(spacing: 8) {
                Text("Interest:")
                    .font(.title2).bold()
                Text(result)
                    .font(.title2).bold()
                    .foregroundColor(.blue)
            }
        }
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !history.isEmpty {
                Text("History")
                    .font(.headline)
                ForEach(history, id: \.self) { item in
                    Text(item)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 12)
    }
    
    private func getButton(_ text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.callout)
                .bold()
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
    
    private func calculate() {
        let t = Double(time) ?? 0
        let r = Double(interest) ?? 0
        let p = Double(principal) ?? 0
        
        var resultData: Double = 0
        var type = "SI"
        
        if isCompound {
            resultData = p * pow((1 + r/100), t) - p
            type = "CI"
        } else {
            resultData = (p * r * t) / 100
            type = "SI"
        }
        
        result = String(format: "%.2f", resultData)
        
        let record = "[\(type)] ₹\(p) at \(r)% for \(t) yrs → ₹\(result)"
        history.insert(record, at: 0)
    }
    
    private func reset() {
        principal = ""
        time = ""
        interest = ""
        result = "₹0.00"
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN") // Indian Rupees
        return formatter.string(from: NSNumber(value: value)) ?? "₹0.00"
    }
}

struct TextInputModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .keyboardType(.decimalPad)
            .background(Color.white)
            .cornerRadius(6)
            .shadow(color: .gray.opacity(0.4), radius: 2, x: 0, y: 1)
            .padding(.bottom, 8)
    }
}
