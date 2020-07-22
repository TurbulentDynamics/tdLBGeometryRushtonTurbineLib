//
//  File.swift
//
//
//  Created by Niall Ó Broin on 24/03/2020.
//
import XCTest
@testable import tdGeometryRushtonTurbineLib

class dataTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testMidPointGeometry() {

        let g = GeometryMidPoint(gridX: 300, gridY: 300, gridZ: 300, uav: 0.1)

        XCTAssertEqual(g.gridX, 300)

        var geom = g.geomFixed
        geom.append(contentsOf: g.geomRotating)

        XCTAssertEqual(geom.count, 344936)

    }

    func testGeometryLegacy() {

        let g = GeometryLegacy(gridX: 300, gridY: 300, gridZ: 300, uav: 0.1)

        var geomLegacy = g.geomFixed
        geomLegacy.append(contentsOf: g.geomRotating)

        XCTAssertEqual(geomLegacy.count, 807048)

    }

    func testCompareLegacyToMidPoint() {

        let gLegacy = GeometryLegacy(gridX: 300, gridY: 300, gridZ: 300, uav: 0.1)
        var geomLegacy = gLegacy.geomFixed
        geomLegacy.append(contentsOf: gLegacy.geomRotating)

        let gMidPoint = GeometryMidPoint(gridX: 300, gridY: 300, gridZ: 300, uav: 0.1)
        var geomMidPoint = gMidPoint.geomFixed
        geomMidPoint.append(contentsOf: gMidPoint.geomRotating)

//        XCTAssertEqual(geomMidPoint, geomLegacy)

    }

    func testSampleTurbineConfig() {

        let (TurbineES, OutputES) = useEggelsSomersRatios(gridX: 300, uav: 0.1)

        XCTAssertEqual(TurbineES.tankDiameter, 298)
        XCTAssertEqual(TurbineES.numImpellers, 1)
        XCTAssertEqual(TurbineES.impeller[0]!.blades.top, 188)

        XCTAssertEqual(OutputES.ortho2DXY[0].at, 149)

        let TurbineGUIDemo = getTurbineTestData()
        XCTAssertEqual(TurbineGUIDemo.tankDiameter, 300)
        XCTAssertEqual(TurbineGUIDemo.numImpellers, 3)
        XCTAssertEqual(TurbineGUIDemo.impeller[0]!.blades.top, 240)
        XCTAssertEqual(TurbineGUIDemo.impeller[1]!.blades.top, 20)

        //        turbines.append(getLegacy(gridx: <#T##Int#>, uav: <#T##Double#>, impellerStartupStepsUntilNormalSpeed: <#T##Int#>, startingStep: <#T##Int#>, impellerStartAngle: <#T##Double#>))

    }

    static var allTests = [
        ("testMidPointGeometry", testMidPointGeometry),
        ("testGeometryLegacy", testGeometryLegacy),
        ("testSampleTurbineConfig", testSampleTurbineConfig)
    ]

}
