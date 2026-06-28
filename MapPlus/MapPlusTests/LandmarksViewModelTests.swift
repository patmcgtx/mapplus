//
//  LandmarksViewModelTests.swift
//  MapPlusTests
//
//  Created by Patrick McGonigle on 6/28/26.
//
import Foundation
import Testing
import SwiftData
import CoreLocation
@testable import MapPlus

@MainActor
@Suite("LandmarksViewModel Tests")
struct LandmarksViewModelTests {

    // MARK: - Helpers

    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: Landmark.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    private func fetchAll(from context: ModelContext) throws -> [Landmark] {
        try context.fetch(FetchDescriptor<Landmark>())
    }

    // MARK: - Initial State

    @Test("View model initializes with correct default state")
    func testInitialState() {
        let viewModel = LandmarksViewModel()

        #expect(!viewModel.showLandmarkForm)
        #expect(viewModel.landmarkToEdit == nil)
        #expect(!viewModel.didDeleteLandmark)
    }

    // MARK: - UI State

    @Test("showLandmarkForm can be toggled")
    func testShowLandmarkForm() {
        let viewModel = LandmarksViewModel()

        viewModel.showLandmarkForm = true
        #expect(viewModel.showLandmarkForm)

        viewModel.showLandmarkForm = false
        #expect(!viewModel.showLandmarkForm)
    }

    @Test("landmarkToEdit can be set and cleared")
    func testLandmarkToEdit() {
        let viewModel = LandmarksViewModel()
        let landmark = Landmark(name: "Test Place")

        viewModel.landmarkToEdit = landmark
        #expect(viewModel.landmarkToEdit === landmark)

        viewModel.landmarkToEdit = nil
        #expect(viewModel.landmarkToEdit == nil)
    }

    // MARK: - Delete

    @Test("Deleting a landmark removes it from the store")
    func testDeleteLandmark() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let viewModel = LandmarksViewModel()

        let landmark = Landmark(name: "Alamo", location: .init(latitude: 29.4259, longitude: -98.4861))
        try LandmarkStore(modelContext: context).commit(landmark: landmark)

        let landmarks = try fetchAll(from: context)
        #expect(landmarks.count == 1)

        viewModel.deleteLandmarks(at: IndexSet(integer: 0), in: landmarks, modelContext: context)

        #expect(try fetchAll(from: context).isEmpty)
    }

    @Test("Deleting a landmark toggles didDeleteLandmark")
    func testDeleteTogglesHapticTrigger() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let viewModel = LandmarksViewModel()

        let landmark = Landmark(name: "Alamo", location: .init(latitude: 29.4259, longitude: -98.4861))
        try LandmarkStore(modelContext: context).commit(landmark: landmark)

        #expect(!viewModel.didDeleteLandmark)

        let landmarks = try fetchAll(from: context)
        viewModel.deleteLandmarks(at: IndexSet(integer: 0), in: landmarks, modelContext: context)

        #expect(viewModel.didDeleteLandmark)
    }

    @Test("Deleting one landmark leaves others intact")
    func testDeleteOnlyTargetLandmark() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let store = LandmarkStore(modelContext: context)
        let viewModel = LandmarksViewModel()

        let first = Landmark(name: "Alamo", location: .init(latitude: 29.4259, longitude: -98.4861))
        let second = Landmark(name: "River Walk", location: .init(latitude: 29.4241, longitude: -98.4936))
        try store.commit(landmark: first)
        try store.commit(landmark: second)

        let landmarks = try fetchAll(from: context)
        #expect(landmarks.count == 2)

        let indexToDelete = try #require(landmarks.firstIndex(where: { $0.name == "Alamo" }))
        viewModel.deleteLandmarks(at: IndexSet(integer: indexToDelete), in: landmarks, modelContext: context)

        let remaining = try fetchAll(from: context)
        #expect(remaining.count == 1)
        #expect(remaining.first?.name == "River Walk")
    }
}
