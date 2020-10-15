//
//  Sidebar.swift
//  Bombardier
//
//  Created by Nindi Gill on 18/8/20.
//

import SwiftUI

struct Sidebar: View {
    @EnvironmentObject var preferences: Preferences
    @Binding var displayType: DisplayType
    var models: [Model]
    @Binding var selectedModel: Model?
    var packages: [Package]
    @Binding var selectedPackage: Package?
    @State private var filter: Bool = false
    @State private var family: Model.Family = .imac
    @State private var sort: Bool = true
    @State private var ascending: Bool = false
    @State private var searchString: String = ""
    private let width: CGFloat = 400

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Picker("Display", selection: $displayType) {
                    ForEach(DisplayType.allCases) { type in
                        Text(type.description)
                            .tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .labelsHidden()
                .controlSize(.large)
                HStack {
                    Toggle("Sort:", isOn: $sort)
                    Picker("Sort", selection: $ascending) {
                        Text("Most recent to least recent")
                            .tag(false)
                        Text("Least recent to most recent")
                            .tag(true)
                    }
                    .labelsHidden()
                    .disabled(!sort)
                }
                HStack {
                    Toggle("Filter:", isOn: $filter)
                    Picker("Filter", selection: $family) {
                        ForEach(Model.Family.allCases) { type in
                            Text(type.description)
                                .tag(type)
                        }
                    }
                    .labelsHidden()
                    .disabled(!filter)
                }
                TextField("Search", text: $searchString)
            }
            .padding()
            switch displayType {
            case .models:
                List(selection: $selectedModel) {
                    ForEach(filteredModels()) { model in
                        SidebarModelRow(model: model)
                            .tag(model)
                            .id(UUID().uuidString)
                    }
                }
                .listStyle(SidebarListStyle())
            case .packages:
                List(selection: $selectedPackage) {
                    ForEach(filteredPackages()) { package in
                        SidebarPackageRow(package: package)
                            .tag(package)
                            .id(UUID().uuidString)
                    }
                }
                .listStyle(SidebarListStyle())
            }
        }
        .frame(minWidth: width, maxWidth: width, maxHeight: .infinity)
    }

    private func filteredModels() -> [Model] {

        var filteredModels: [Model] = []

        if filter {
            filteredModels = models.filter {
                $0.family == family
            }

            if sort {
                filteredModels = ascending ? filteredModels : filteredModels.reversed()
            }
        } else {
            for type in Model.Family.allCases {
                var filteredFamily: [Model] = models.filter {
                    $0.family == type
                }

                if sort {
                    filteredFamily = ascending ? filteredFamily : filteredFamily.reversed()
                }

                filteredModels += filteredFamily
            }
        }

        if !searchString.isEmpty {

            var validModels: [Model] = []

            for filteredModel in filteredModels {

                let nameMatch: Bool = filteredModel.name.lowercased().contains(searchString.lowercased())
                let identifierMatch: Bool = filteredModel.modelIdentifier.lowercased().contains(searchString.lowercased())

                if nameMatch || identifierMatch {
                    validModels.append(filteredModel)
                }
            }

            filteredModels = validModels
        }

        return filteredModels
    }

    private func filteredPackages() -> [Package] {

        var filteredPackages: [Package] = []

        if filter {

            for package in packages {

                if !package.supportedModels(from: models).filter({ $0.family == family }).isEmpty {
                    filteredPackages.append(package)
                }
            }
        } else {
            filteredPackages = packages
        }

        if sort {
            filteredPackages = filteredPackages.sorted {
                ascending ? $0.date < $1.date : $0.date > $1.date
            }
        }

        if !searchString.isEmpty {

            var validPackages: [Package] = []

            for filteredPackage in filteredPackages {

                let nameMatch: Bool = filteredPackage.name.lowercased().contains(searchString.lowercased())
                let dateMatch: Bool = filteredPackage.formattedDate(dateStyle: .full, timeStyle: .full).lowercased()
                    .contains(searchString.lowercased())

                if nameMatch || dateMatch {
                    validPackages.append(filteredPackage)
                }
            }

            filteredPackages = validPackages
        }

        return filteredPackages
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        Sidebar(displayType: .constant(.models), models: [.example], selectedModel: .constant(nil), packages: [.example], selectedPackage: .constant(nil))
    }
}
