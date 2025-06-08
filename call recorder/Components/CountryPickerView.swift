import SwiftUI

struct CountryPickerView: View {
    @Binding var selectedCountry: Country
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var filteredCountries: [Country] {
        if searchText.isEmpty {
            return Country.allCountries
        } else {
            return Country.allCountries.filter { country in
                country.name.localizedCaseInsensitiveContains(searchText) ||
                country.dialCode.contains(searchText) ||
                country.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.darkGrey)
                    
                    TextField("Search countries", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color.lightGrey)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Countries List
                List {
                    ForEach(filteredCountries) { country in
                        CountryRow(
                            country: country,
                            isSelected: country.id == selectedCountry.id
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCountry = country
                            dismiss()
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.skyBlue)
                }
            }
        }
    }
}

struct CountryRow: View {
    let country: Country
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Text(country.flag)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(country.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.navyBlue)
                
                Text(country.dialCode)
                    .font(.caption)
                    .foregroundColor(.darkGrey)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.skyBlue)
                    .font(.footnote)
                    .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 8)
        .background(isSelected ? Color.skyBlue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

#Preview {
    CountryPickerView(selectedCountry: .constant(Country.defaultCountry))
}