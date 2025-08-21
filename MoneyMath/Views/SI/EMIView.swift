import SwiftUI
import Charts

// MARK: - Data Models
struct EMIMonth: Identifiable {
    let id = UUID()
    let month: Int
    let principal: Double
    let interest: Double
    let balance: Double
}

struct Prepayment: Identifiable {
    let id = UUID()
    var month: Int
    var amount: Double
}

struct SliderInput: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let formatter: (Double) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(formatter(value))
                    .bold()
            }
            Slider(
                value: Binding(
                    get: { min(max(value, range.lowerBound), range.upperBound) },
                    set: { value = min(max($0, range.lowerBound), range.upperBound) }
                ),
                in: range,
                step: max(step, 0.01) // ensure positive stride
            )
        }
    }
}

struct EMIView: View {
    @State private var loanAmount: Double = 1000000
    @State private var interestRate: Double = 8.5
    @State private var tenure: Double = 120
    
    @State private var prepayments: [Prepayment] = []
    @State private var reduceTenure = true
    
    @State private var emiResult = "₹0"
    @State private var schedule: [EMIMonth] = []
    @State private var interestSaved = "₹0"
    @State private var newTenureDisplay = ""
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Loan Inputs
                    CardView(title: "Loan Details") {
                        SliderInput(title: "Loan Amount",
                                    value: $loanAmount,
                                    range: 100000...20000000,
                                    step: 10000,
                                    formatter: { "₹\(Int($0))" })
                        
                        SliderInput(title: "Interest Rate",
                                    value: $interestRate,
                                    range: 1...20,
                                    step: 0.1,
                                    formatter: { String(format: "%.2f%%", $0) })
                        
                        SliderInput(title: "Tenure (Months)",
                                    value: $tenure,
                                    range: 1...360,
                                    step: 1,
                                    formatter: { "\(Int($0)) months" })
                    }
                    
                    // Prepayment Inputs
                    CardView(title: "Prepayments") {
                        ForEach($prepayments) { $prepay in
                            VStack(alignment: .leading) {
                                SliderInput(title: "Prepayment Month",
                                            value: $prepay.month.doubleBinding,
                                            range: 1...tenure,
                                            step: 1,
                                            formatter: { "Month \(Int($0))" })
                                
                                SliderInput(title: "Prepayment Amount",
                                            value: $prepay.amount,
                                            range: 10000...loanAmount,
                                            step: 10000,
                                            formatter: { "₹\(Int($0))" })
                            }
                            Divider()
                        }
                        
                        Button {
                            prepayments.append(Prepayment(month: Int(tenure/2), amount: 100000))
                        } label: {
                            Label("Add Prepayment", systemImage: "plus.circle.fill")
                        }
                    }
                    
                    Toggle("Reduce Tenure Instead of EMI", isOn: $reduceTenure)
                        .padding(.horizontal)
                    
                    Button(action: calculateEMI) {
                        Text("Calculate EMI")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    // Results
                    if !schedule.isEmpty {
                        CardView(title: "Results") {
                            HStack {
                                Text("Monthly EMI:")
                                    .font(.title2).bold()
                                Spacer()
                                Text(emiResult)
                                    .font(.title2).bold()
                                    .foregroundColor(.blue)
                            }
                            if !newTenureDisplay.isEmpty {
                                Text(newTenureDisplay)
                                    .font(.subheadline)
                            }
                            if interestSaved != "₹0" {
                                Text("Estimated Interest Saved: \(interestSaved)")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        // Charts
                        CardView(title: "Outstanding Balance Over Time") {
                            Chart(schedule) { month in
                                LineMark(
                                    x: .value("Month", month.month),
                                    y: .value("Balance", month.balance)
                                )
                            }
                            .chartXAxis {
                                let totalMonths = schedule.last?.month ?? 1
                                let maxYear = (totalMonths + 11) / 12
                                
                                if maxYear <= 7 {
                                    // Generate an array of month values at the start of each year
                                    let yearMonths = (1...maxYear).map { Double(($0 - 1) * 12 + 1) }
                                    
                                    AxisMarks(values: yearMonths) { value in
                                        let monthNum = value.as(Int.self) ?? 0
                                        let year = (monthNum + 11) / 12
                                        
                                        AxisValueLabel("Y\(year)")
                                            .font(.caption2)
                                        AxisGridLine()
                                    }
                                } else {
                                    // Generate a custom array of 7 evenly spaced year labels
                                    let step = max(1, Int(Double(maxYear) / 6.0))
                                    let years = stride(from: 1, through: maxYear, by: step)
                                    let desiredMonths = years.map { Double(($0 - 1) * 12 + 1) }
                                    
                                    AxisMarks(values: desiredMonths) { value in
                                        let monthNum = value.as(Int.self) ?? 0
                                        let year = (monthNum + 11) / 12
                                        
                                        AxisValueLabel("Y\(year)")
                                            .font(.caption2)
                                        AxisGridLine()
                                    }
                                }
                            }
                            .frame(height: 200)
                        }
                        
                        let totalPrincipal = schedule.map { $0.principal }.reduce(0, +)
                        let totalInterest = schedule.map { $0.interest }.reduce(0, +)
                        CardView(title: "Principal vs Interest") {
                            PieChart(data: [
                                (label: "Principal", value: totalPrincipal, color: .blue),
                                (label: "Interest", value: totalInterest, color: .red)
                            ])
                            .frame(height: 200)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("EMI Calculator")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Calculation
    private func calculateEMI() {
        let principal = loanAmount
        let monthlyRate = interestRate / 12 / 100
        let totalMonths = Int(tenure)
        
        guard principal > 0, monthlyRate > 0, totalMonths > 0 else {
            resetResults()
            return
        }
        
        let ratePow = pow(1 + monthlyRate, Double(totalMonths))
        var emi = (principal * monthlyRate * ratePow) / (ratePow - 1)
        
        var balance = principal
        var tempSchedule: [EMIMonth] = []
        let originalInterest = calculateTotalInterest(principal: principal, emi: emi, months: totalMonths, rate: monthlyRate)
        
        let prepayDict = Dictionary(uniqueKeysWithValues: prepayments.map { ($0.month, $0.amount) })
        
        for month in 1...totalMonths {
            let interest = balance * monthlyRate
            let principalPaid = emi - interest
            balance -= principalPaid
            
            // Prepayment check
            if let preAmt = prepayDict[month], preAmt > 0 {
                balance = max(balance - preAmt, 0)
                
                if reduceTenure {
                    let remMonths = totalMonths - month
                    if balance > 0, remMonths > 0 {
                        let newMonths = log(emi / (emi - balance * monthlyRate)) / log(1 + monthlyRate)
                        let adjustedRem = Int(ceil(newMonths))
                        newTenureDisplay = "Remaining Tenure: \(adjustedRem) months"
                    } else {
                        newTenureDisplay = "Loan closed!"
                    }
                } else {
                    let remMonths = totalMonths - month
                    if balance > 0, remMonths > 0 {
                        let rp = pow(1 + monthlyRate, Double(remMonths))
                        emi = (balance * monthlyRate * rp) / (rp - 1)
                        emiResult = String(format: "₹%.0f", emi.rounded())
                    } else {
                        emi = 0
                        emiResult = "₹0"
                    }
                }
            }
            
            tempSchedule.append(EMIMonth(month: month,
                                         principal: principalPaid,
                                         interest: interest,
                                         balance: max(balance, 0)))
            if balance <= 0 { break }
        }
        
        schedule = tempSchedule
        let newInterest = schedule.map { $0.interest }.reduce(0, +)
        let saved = originalInterest - newInterest
        interestSaved = "₹\(Int(saved.rounded()))"
        
        if emiResult == "₹0" {
            emiResult = "₹\(Int(emi.rounded()))"
        }
    }
    
    private func resetResults() {
        emiResult = "₹0"
        schedule = []
        interestSaved = "₹0"
        newTenureDisplay = ""
    }
    
    private func calculateTotalInterest(principal: Double, emi: Double, months: Int, rate: Double) -> Double {
        var balance = principal
        var totalInterest = 0.0
        for _ in 1...months {
            let interest = balance * rate
            let principalPortion = emi - interest
            balance -= principalPortion
            totalInterest += interest
            if balance <= 0 { break }
        }
        return totalInterest
    }
}

// MARK: - Reusable Card
struct CardView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

// MARK: - PieChart
struct PieChart: View {
    let data: [(label: String, value: Double, color: Color)]
    var total: Double {
        data.map { $0.value }.reduce(0, +)
    }
    var body: some View {
        GeometryReader { geo in
            if total == 0 {
                Text("No data")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack {
                    ForEach(0..<data.count, id: \.self) { i in
                        let start = angle(at: i)
                        let end = angle(at: i + 1)
                        Path { path in
                            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                            path.move(to: center)
                            path.addArc(center: center,
                                        radius: min(geo.size.width, geo.size.height) / 2,
                                        startAngle: start,
                                        endAngle: end,
                                        clockwise: false)
                        }
                        .fill(data[i].color)
                    }
                }
            }
        }
    }
    private func angle(at index: Int) -> Angle {
        guard total > 0 else { return .degrees(0) }
        let sum = data.prefix(index).map { $0.value }.reduce(0, +)
        return .degrees(360 * sum / total)
    }
}

// MARK: - Helpers
extension Int {
    var doubleBinding: Double {
        get { Double(self) }
        set { self = Int(newValue) }
    }
}

// MARK: - Preview
struct EMIView_Previews: PreviewProvider {
    static var previews: some View {
        EMIView()
    }
}
