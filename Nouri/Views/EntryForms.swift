import NouriKit
import SwiftUI

/// Adds a drink, or edits one when `editing` is set.
struct FluidForm: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    private let editing: FluidItem?
    @State private var amount: Double
    @State private var beverage: BeverageType
    @State private var calories: Double
    @State private var time: Date
    @State private var caloriesEdited: Bool

    init(editing: FluidItem? = nil) {
        self.editing = editing
        _amount = State(initialValue: editing?.amountML ?? 250)
        _beverage = State(initialValue: editing?.beverage ?? .water)
        _calories = State(initialValue: editing?.calories ?? 0)
        _time = State(initialValue: editing?.timestamp ?? .now)
        _caloriesEdited = State(initialValue: editing != nil)
    }

    /// 50 ml steps; an edited entry keeps its exact amount even when it's off-step.
    private var amountOptions: [Double] {
        let steps = Array(stride(from: 50.0, through: 2000, by: 50))
        return steps.contains(amount) ? steps : (steps + [amount]).sorted()
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Drink", selection: $beverage) {
                    ForEach(BeverageType.allCases) { type in
                        Label(type.title, systemImage: type.symbol).tag(type)
                    }
                }
                Picker("Amount (ml)", selection: $amount) {
                    ForEach(amountOptions, id: \.self) { ml in
                        Text("\(Format.ml(ml)) ml").tag(ml)
                    }
                }
                .pickerStyle(.wheel)
                .accessibilityIdentifier("fluid-amount")
                LabeledContent("Calories (kcal)") {
                    TextField("kcal", value: Binding(get: { calories }, set: { calories = $0; caloriesEdited = true }),
                              format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
                DatePicker("Time", selection: $time, in: ...Date.now)
                    .accessibilityIdentifier("fluid-time")
            }
            .onChange(of: beverage) { prefillCalories() }
            .onChange(of: amount) { prefillCalories() }
            .navigationTitle(editing == nil ? "Add Drink" : "Edit Drink")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editing == nil ? "Add" : "Save") {
                        if let editing {
                            model.updateFluid(FluidItem(id: editing.id, amountML: amount, beverage: beverage,
                                                        calories: calories, timestamp: time))
                        } else {
                            model.addFluid(amount, beverage: beverage, calories: calories, timestamp: time)
                        }
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

/// Adds food, or edits an entry when `editing` is set.
struct FoodForm: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    private let editing: FoodItem?
    @State private var name: String
    @State private var calories: Double?
    @State private var time: Date
    @State private var saveAsPreset = false

    init(editing: FoodItem? = nil) {
        self.editing = editing
        _name = State(initialValue: editing?.name ?? "")
        _calories = State(initialValue: editing?.calories)
        _time = State(initialValue: editing?.timestamp ?? .now)
    }

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
                DatePicker("Time", selection: $time, in: ...Date.now)
                if editing == nil {
                    Toggle("Save as quick preset", isOn: $saveAsPreset)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle(editing == nil ? "Add Food" : "Edit Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editing == nil ? "Add" : "Save") {
                        guard let calories else { return }
                        if let editing {
                            model.updateFood(FoodItem(id: editing.id, name: name, calories: calories, timestamp: time))
                        } else {
                            model.addCalories(calories, name: name, timestamp: time)
                            if saveAsPreset { model.addPreset(name: name, calories: calories) }
                        }
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

extension FoodItem {
    /// Entries logged with a quick-add button have no name.
    var displayName: String { name.isEmpty ? String(localized: "Quick add") : name }
}
