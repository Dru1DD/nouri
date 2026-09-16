import NouriKit
import SwiftUI

struct AddFluidView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var amount: Double = 250
    @State private var beverage: BeverageType = .water
    @State private var calories: Double = 0
    @State private var caloriesEdited = false

    var body: some View {
        NavigationStack {
            Form {
                Picker("Drink", selection: $beverage) {
                    ForEach(BeverageType.allCases) { type in
                        Label(type.title, systemImage: type.symbol).tag(type)
                    }
                }
                LabeledContent("Amount (ml)") {
                    TextField("ml", value: $amount, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifier("fluid-amount")
                }
                LabeledContent("Calories (kcal)") {
                    TextField("kcal", value: Binding(get: { calories }, set: { calories = $0; caloriesEdited = true }),
                              format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            .onChange(of: beverage) { prefillCalories() }
            .onChange(of: amount) { prefillCalories() }
            .navigationTitle("Add Drink")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        model.addFluid(amount, beverage: beverage, calories: calories)
                        dismiss()
                    }
                    .disabled(amount <= 0)
                    .accessibilityIdentifier("fluid-save")
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func prefillCalories() {
        guard !caloriesEdited else { return }
        calories = beverage.defaultCalories(amountML: amount)
    }
}

struct AddFoodView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var calories: Double?
    @State private var saveAsPreset = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name (optional)", text: $name)
                LabeledContent("Calories (kcal)") {
                    TextField("kcal", value: $calories, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .accessibilityIdentifier("food-calories")
                }
                Toggle("Save as quick preset", isOn: $saveAsPreset)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard let calories else { return }
                        model.addCalories(calories, name: name)
                        if saveAsPreset { model.addPreset(name: name, calories: calories) }
                        dismiss()
                    }
                    .disabled((calories ?? 0) <= 0)
                    .accessibilityIdentifier("food-save")
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
