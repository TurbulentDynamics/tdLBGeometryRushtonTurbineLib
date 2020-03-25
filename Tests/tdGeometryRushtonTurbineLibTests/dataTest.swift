//
//  File.swift
//
//
//  Created by Niall Ó Broin on 24/03/2020.
//
import XCTest
@testable import tdGeometryRushtonTurbineLib

class dataTests: XCTestCase {


    private var turb: TurbineState!

    override func setUp() {
        super.setUp()

        let filestr = "/Users/nile/Workspace/xcode/tdGeometryRushtonTurbineLib/Sources/tdGeometryRushtonTurbineLib/tdGeometryRushtonTurbine-sample.json"
        let url = URL(fileURLWithPath: filestr)

        do {
            turb = try readTurbineState(url)
        } catch {
            print(error)
        }
    }


    func testCreateTankWall(){
        let numPointsOnCircle:Double = 30
        let dθ = 2 * Double.pi / numPointsOnCircle

        let wall:[GeomPoints] = createTankWall(height: 300, diameter: 300, dθ: dθ)
        XCTAssertEqual(wall.count, 300 * 30)
    }



    static var allTests = [
        ("testCreateTankWall", testCreateTankWall),
    ]

}
