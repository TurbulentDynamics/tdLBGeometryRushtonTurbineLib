//
//  File.swift
//
//
//  Created by Niall Ó Broin on 24/03/2020.
//
import XCTest
@testable import tdLBGeometryRushtonTurbineLib

class dataTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testMidPointGeometry() {

        let g = RushtonTurbineMidPoint(gridX: 300, gridY: 300, gridZ: 300, uav: 0.1)

        XCTAssertEqual(g.gridX, 300)

        var geom = g.geomFixed
        geom.append(contentsOf: g.geomRotating)

        XCTAssertEqual(geom.count, 344936)

    }

    func testGeometryLegacy() {

        let g = RushtonTurbineLegacy(gridX: 300, gridY: 300, gridZ: 300, uav: 0.1)

        var geomLegacy = g.geomFixed
        geomLegacy.append(contentsOf: g.geomRotating)

        XCTAssertEqual(geomLegacy.count, 807048)

    }

    func testCompareLegacyToMidPoint() {

        let gMidPoint = RushtonTurbineMidPoint(gridX: 300, gridY: 300, gridZ: 300, uav: 0.1)
        var geomMidPoint = gMidPoint.geomFixed
        geomMidPoint.append(contentsOf: gMidPoint.geomRotating)


        let gLegacy = RushtonTurbineLegacy(gridX: 300, gridY: 300, gridZ: 300, uav: 0.1)
        var geomLegacy = gLegacy.geomFixed
        geomLegacy.append(contentsOf: gLegacy.geomRotating)


//        XCTAssertEqual(geomMidPoint, geomLegacy)

    }

    func testSampleTurbineConfig() {

        let turbineES = getEggelsSomersGeometry(gridX: 300, uav: 0.1)
        let outputES = exampleTurbineOutput(turbine: turbineES)
            
        XCTAssertEqual(turbineES.tankDiameter, 298)
        XCTAssertEqual(turbineES.numImpellers, 1)
        XCTAssertEqual(turbineES.impeller["0"]?.blades.top, 188)

        XCTAssertEqual(outputES.ortho2DXY[0].at, 148)

        let TurbineGUIDemo = getTurbineTestData()
        XCTAssertEqual(TurbineGUIDemo.tankDiameter, 300)
        XCTAssertEqual(TurbineGUIDemo.numImpellers, 3)
        XCTAssertEqual(TurbineGUIDemo.impeller["0"]?.blades.top, 240)
    }

    static var allTests = [
        ("testMidPointGeometry", testMidPointGeometry),
        ("testGeometryLegacy", testGeometryLegacy),
        ("testSampleTurbineConfig", testSampleTurbineConfig)
    ]

}
