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

        XCTAssertEqual(geom.count, 86276)

    }


    func testSampleTurbineConfig() {

        let turbineES = getEggelsSomersGeometry(gridX: 300, uav: 0.1)
        let outputES = exampleTurbineOutput(turbine: turbineES)
            
        XCTAssertEqual(turbineES.tankDiameter, 298)
        XCTAssertEqual(turbineES.impellers["0"]?.blades.top, 188)

        XCTAssertEqual(outputES.ortho2DXY[0].at, 148)

        let TurbineGUIDemo = getTurbineTestData()
        XCTAssertEqual(TurbineGUIDemo.tankDiameter, 300)
        XCTAssertEqual(TurbineGUIDemo.impellers["0"]?.blades.top, 240)
    }

    static var allTests = [
        ("testMidPointGeometry", testMidPointGeometry),
        ("testSampleTurbineConfig", testSampleTurbineConfig)
    ]

}
