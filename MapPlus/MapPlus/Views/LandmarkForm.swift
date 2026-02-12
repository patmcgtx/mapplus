//
//  LandmarkForm.swift
//  MapPlus
//
//  Created by Patrick McGonigle on 1/27/26.
//

import SwiftUI
import SFSafeSymbols

import SwiftUI
import CoreLocation
import MapKit

@Observable
class OldLocationManager: NSObject, CLLocationManagerDelegate {
    
    var location: CLLocation? = nil
    var resolvedAddress: AddressInfo? = nil
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestUserAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startCurrentLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("+++ Found user's location...")
        guard let location = locations.first else { return }
        print("+++ Found user's location: \(location)")
        let mapItem = MKMapItem(location: location, address: nil)
        self.location = location
        self.resolvedAddress = AddressInfo(
            formattedDescription: mapItem.fullDescription,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("+++ Failed to find user's location: \(error.localizedDescription)")
    }
}

// TODO patmcg doc
struct LandmarkForm: View {
    
    init(
        mode: LandmarkFormViewModel.Mode,
        addressLookupService: AddressLookupProtocol = MapKitAddressLookupService()
    ) {
        self.viewModel = LandmarkFormViewModel(mode: mode)
        self.addressLookupService = addressLookupService
    }
    
    @State var oldLocationManager = OldLocationManager()

    // View model owns the form mode and configuration
    private let viewModel: LandmarkFormViewModel
    
    // Location lookup service
    private let addressLookupService: AddressLookupProtocol
        
    // Environment
    @Environment(\.dismiss) private var dismiss
    
    // Persistence
    @Environment(\.modelContext) private var modelContext
    private var storageService: LandmarkStorageService {
        LandmarkStorageService(modelContext: self.modelContext)
    }
    
    // Form state
    @State private var landmarkName: String = ""
    @State private var landmarkIconName: String = "mappin.circle"
    @State private var landmarkNotes: String = ""
    
    // Icon picker state
    @State private var showingIconPicker: Bool = false
    
    // Error state
    @State private var showingSaveError: Bool = false
    @State private var saveErrorMessage: String = ""
    
    // Location lookup state
    @State private var landmarkAddressInput: String = ""
    @State private var addressSearchState: AddressSearchState = .initial
    
    private enum AddressSearchState {
        case initial
        case searching
        case success(AddressInfo)
        case failure(Error)
    }
    
    var body: some View {
        Form {
            Section("Details") {
                HStack {
                    TextField("Name", text: $landmarkName,
                              onEditingChanged: { _ in
                    })
                    .autocorrectionDisabled()
                    Button {
                        self.landmarkName = ""
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }
                Button {
                    self.showingIconPicker = true
                } label: {
                    Label("Icon...", systemImage: landmarkIconName)
                }
            }
            Section("Notes") {
                TextEditor(text: $landmarkNotes)
            }
            if case .create = self.viewModel.mode {
                Section("Location") {
                    HStack {
                        TextField(
                            "Address or location name",
                            text: $landmarkAddressInput,
                            onEditingChanged: { _ in
                                self.lookupAddress()
                            })
                        .autocorrectionDisabled()
                        Button {
                            self.getCurrentLocation()
                        } label: {
                            Image(systemName: "location")
                        }
                        Button {
                            self.lookupAddress()
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                }
            }
            Section("Preview") {
                HStack {
                    HStack {
                        VStack {
                            Spacer()
                            Image(systemName: self.landmarkIconName)
                            Spacer()
                            Text(self.landmarkName)
                            Spacer()
                        }
                        .multilineTextAlignment(.center)
                        .padding()
                        Spacer()
                        switch self.addressSearchState {
                        case .initial:
                            EmptyView()
                        case .searching:
                            ProgressView()
                        case .success(let resolvedAddress):
                            Text(resolvedAddress.formattedDescription)
                        case .failure(let error):
                            Text(error.localizedDescription)
                        }
//                        Spacer()
                        Text(self.oldLocationManager.resolvedAddress?.formattedDescription ?? "current loc nil")
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Label("Cancel", systemImage: "x.circle")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    do {
                        switch self.addressSearchState {
                        case .initial, .searching, .failure:
                            break
                        case .success(let resolvedAddress):
                            try self.storageService.save(
                                address: resolvedAddress,
                                name: self.landmarkName,
                                notes: self.landmarkNotes,
                                iconName: self.landmarkIconName
                            )
                        }
                        self.dismiss()
                    } catch {
                        self.saveErrorMessage = error.localizedDescription
                        self.showingSaveError = true
                    }
                }
                .disabled(!self.isSaveEnabled)
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .navigationTitle(self.viewModel.formTitle)
        .alert("Oops", isPresented: $showingSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveErrorMessage.isEmpty ? "Failed to save" : saveErrorMessage)
        }
        .sheet(isPresented: $showingIconPicker) {
            IconPicker(
                landmarkIconName: $landmarkIconName,
                iconsToShow: viewModel.iconsToShow
            )
        }
        .scrollDismissesKeyboard(ScrollDismissesKeyboardMode.immediately)
        .onAppear() {
            switch self.viewModel.mode {
            case .create:
                break
            case .edit(let landmark):
                self.landmarkName = landmark.name
                self.landmarkIconName = landmark.systemImageName
                self.landmarkNotes = landmark.notes
                self.addressSearchState = .success(AddressInfo(
                    formattedDescription: landmark.formattedAddress,
                    latitude: landmark.location.latitude,
                    longitude: landmark.location.longitude)
                )
            }
        }
        .task {
            oldLocationManager.requestUserAuthorization()
        }
//        .onChange(of: self.oldLocationManager.resolvedAddress) { oldValue, newValue in
//            if let newValue {
//                self.addressSearchState = .success(newValue)
//            }
//        }
    }
    
    // MARK: - Internal helpers

    private func getCurrentLocation() {
        self.addressSearchState = .searching
        oldLocationManager.startCurrentLocationUpdates()
    }
    
    /// Runs a background address lookup and updates the UI with the result.
    private func lookupAddress() {
        Task {
            do {
                self.addressSearchState = .searching
                let resolved = try await self.addressLookupService.lookup(address: self.landmarkAddressInput)
                self.addressSearchState = .success(resolved)
            } catch {
                self.addressSearchState = .failure(error)
            }
        }
    }
    
    // TODO patmcg Validate landmark name too
    private var isSaveEnabled: Bool {
        switch self.addressSearchState {
        case .initial, .searching, .failure: return false
        case .success: return true
        }
    }
    
    private var isAddressInputValid: Bool {
        self.landmarkAddressInput.isPopulated && self.landmarkAddressInput != MapPlusError.addressNotFound.localizedDescription
    }
    
}

#Preview("Create") {
    LandmarkForm(mode: .create)
}

#Preview("Edit") {
    LandmarkForm(
        mode: .edit(LandmarkSampleData().capital)
    )
}

