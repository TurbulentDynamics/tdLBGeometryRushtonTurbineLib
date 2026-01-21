import XCTest
@testable import tdLBGeometryRushtonTurbineLib

final class RushtonTurbineValidationTests: XCTestCase {

    func testValidTurbineConfiguration() throws {
        let turbine = RushtonTurbineReference(gridX: 300)
        XCTAssertNoThrow(try turbine.validate())
    }

    func testInvalidTankDiameter() {
        let turbine = createTestTurbine(tankDiameter: 0)
        XCTAssertThrowsError(try turbine.validate()) { error in
            guard case RushtonTurbineValidationError.invalidTankDiameter = error else {
                XCTFail("Expected invalidTankDiameter error")
                return
            }
        }
    }

    func testInvalidResolution() {
        let turbine = createTestTurbine(resolution: 0)
        XCTAssertThrowsError(try turbine.validate()) { error in
            guard case RushtonTurbineValidationError.invalidResolution = error else {
                XCTFail("Expected invalidResolution error")
                return
            }
        }
    }

    func testNoImpellers() {
        let turbine = createTestTurbine(impellers: [:])
        XCTAssertThrowsError(try turbine.validate()) { error in
            guard case RushtonTurbineValidationError.noImpellers = error else {
                XCTFail("Expected noImpellers error")
                return
            }
        }
    }

    func testInvalidBaffleRadius() {
        let baffles = Baffles(
            firstBaffleOffset: 0.0,
            innerRadius: 100,
            thickness: 4,
            numBaffles: 4,
            outerRadius: 50  // inner > outer is invalid
        )
        let turbine = createTestTurbine(baffles: baffles)
        XCTAssertThrowsError(try turbine.validate()) { error in
            guard case RushtonTurbineValidationError.invalidBaffleRadius = error else {
                XCTFail("Expected invalidBaffleRadius error")
                return
            }
        }
    }

    // Helper to create a test turbine with overridable parameters
    private func createTestTurbine(
        tankDiameter: Int = 300,
        tankHeight: Int = 300,
        resolution: Double = 0.7,
        impellers: [String: Impeller]? = nil,
        baffles: Baffles? = nil
    ) -> RushtonTurbine {
        let shaft = Shaft(radius: 8)
        let defaultBaffles = baffles ?? Baffles(
            firstBaffleOffset: 0.39,
            innerRadius: 120,
            thickness: 4,
            numBaffles: 4,
            outerRadius: 145
        )
        let blades = Blades(innerRadius: 25, top: 180, thickness: 4, outerRadius: 50, bottom: 220)
        let disk = Disk(top: 198, bottom: 202, radius: 37)
        let hub = Disk(top: 180, bottom: 220, radius: 16)
        let impeller = Impeller(
            blades: blades,
            uav: 0.1,
            bladeTipAngularVelW0: 0.002,
            impellerPosition: 200,
            disk: disk,
            numBlades: 6,
            firstBladeOffset: 0,
            hub: hub
        )
        let defaultImpellers = impellers ?? ["0": impeller]

        return RushtonTurbine(
            tankDiameter: tankDiameter,
            tankHeight: tankHeight,
            impellerStartAngle: 0.0,
            shaft: shaft,
            impeller: defaultImpellers,
            gridX: tankDiameter,
            impellerStartupStepsUntilNormalSpeed: 0,
            baffles: defaultBaffles,
            startingStep: 0,
            name: "Test",
            resolution: resolution
        )
    }
}

final class RushtonTurbineJSONTests: XCTestCase {

    func testJSONRoundTrip() throws {
        let original = RushtonTurbineReference(gridX: 300)
        let jsonData = try original.jsonData()
        let decoded = try RushtonTurbine(data: jsonData)

        XCTAssertEqual(decoded.tankDiameter, original.tankDiameter)
        XCTAssertEqual(decoded.tankHeight, original.tankHeight)
        XCTAssertEqual(decoded.gridX, original.gridX)
        XCTAssertEqual(decoded.resolution, original.resolution)
        XCTAssertEqual(decoded.impellers.count, original.impellers.count)
        XCTAssertEqual(decoded.baffles.numBaffles, original.baffles.numBaffles)
    }

    func testJSONStringRoundTrip() throws {
        let original = RushtonTurbineReference(gridX: 200)
        guard let jsonString = try original.jsonString() else {
            XCTFail("Failed to encode JSON string")
            return
        }
        let decoded = try RushtonTurbine(jsonString)

        XCTAssertEqual(decoded.tankDiameter, original.tankDiameter)
        XCTAssertEqual(decoded.name, original.name)
    }
}

final class GeometryGenerationTests: XCTestCase {

    func testMidPointGeometryGeneration() {
        let geom = RushtonTurbineMidPoint(gridX: 100, gridY: 100, gridZ: 100, uav: 0.1)

        XCTAssertFalse(geom.geomFixed.isEmpty, "Fixed geometry should not be empty")
        XCTAssertFalse(geom.geomRotatingNonUpdating.isEmpty, "Rotating non-updating geometry should not be empty")
        XCTAssertFalse(geom.geomRotating.isEmpty, "Rotating geometry should not be empty")
    }

    func testMidPointGeometryPointCount() {
        let geom = RushtonTurbineMidPoint(gridX: 300, gridY: 300, gridZ: 300, uav: 0.1)

        // These are approximate expected counts - adjust based on actual algorithm
        XCTAssertGreaterThan(geom.geomFixed.count, 1000, "Should generate significant fixed geometry")
        XCTAssertGreaterThan(geom.geomRotating.count, 100, "Should generate blade geometry")
    }

    func testPolarGeometryGeneration() {
        let turbine = RushtonTurbineReference(gridX: 100)
        var geom = RushtonTurbinePolarSwift(turbine: turbine)

        geom.generateFixedGeometry()
        geom.generateRotatingNonUpdatingGeometry()
        geom.generateRotatingGeometry(atθ: 0.0)

        XCTAssertFalse(geom.geomFixed.isEmpty, "Fixed geometry should not be empty")
        XCTAssertFalse(geom.geomRotatingNonUpdating.isEmpty, "Rotating non-updating geometry should not be empty")
        XCTAssertFalse(geom.geomRotating.isEmpty, "Rotating geometry should not be empty")
    }

    func testRotatingGeometryUpdate() {
        let turbine = RushtonTurbineReference(gridX: 100)
        var geom = RushtonTurbinePolarSwift(turbine: turbine)

        geom.generateRotatingGeometry(atθ: 0.0)
        let initialCount = geom.geomRotating.count

        geom.updateRotatingGeometry(atθ: Float.pi / 4)
        let updatedCount = geom.geomRotating.count

        // Point count should remain similar after rotation
        XCTAssertEqual(initialCount, updatedCount, "Rotating geometry count should remain consistent")
    }
}

final class ExtentsTests: XCTestCase {

    func testContainsMethods() {
        // Note: These test the Swift-side behavior; C++ Extents are tested separately
        let turbine = RushtonTurbineReference(gridX: 100)
        XCTAssertEqual(turbine.tankDiameter, 100)
        XCTAssertEqual(turbine.tankHeight, 100)
    }
}

final class ReferenceProportionsTests: XCTestCase {

    func testHartmannDerksenProportions() {
        let turbine = RushtonTurbineReference(gridX: 300)

        // Tank diameter should equal gridX
        XCTAssertEqual(turbine.tankDiameter, 300)
        XCTAssertEqual(turbine.tankHeight, 300)

        // Impeller position should be at 2/3 of tank height
        let impeller = turbine.impellers["0"]!
        let expectedPosition = Int(300.0 * (2.0 / 3.0))
        XCTAssertEqual(impeller.impellerPosition, expectedPosition)

        // D (impeller diameter) should be tankDiameter / 3
        let D = 300.0 / 3.0
        XCTAssertEqual(impeller.blades.outerRadius, Int(D / 2.0))

        // 6 blades standard for Rushton turbine
        XCTAssertEqual(impeller.numBlades, 6)

        // 4 baffles standard
        XCTAssertEqual(turbine.baffles.numBaffles, 4)
    }

    func testDifferentGridSizes() {
        for gridX in [100, 200, 300, 400] {
            let turbine = RushtonTurbineReference(gridX: gridX)
            XCTAssertEqual(turbine.tankDiameter, gridX)
            XCTAssertNoThrow(try turbine.validate())
        }
    }
}
