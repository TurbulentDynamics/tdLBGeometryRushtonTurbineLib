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


    func testMidPointGeometry(){
        let testTurbine = getEggelsSomersConfig(gridx: 300, uav: 0.1, impellerStartupStepsUntilNormalSpeed: 0, startingStep: 0, impellerStartAngle: 0)

        let geom = getMidPointGeometry(turbine: testTurbine)

        XCTAssertEqual(geom.count, 852)

        
    }



    func testGeometryLegacy(){

        let testTurbine = getEggelsSomersConfig(gridx: 300, uav: 0.1, impellerStartupStepsUntilNormalSpeed: 0, startingStep: 0, impellerStartAngle: 0)

        let geom = getGeometryGillersion(turbine: testTurbine)

        XCTAssertEqual(geom.count, 852)


    }




    func testCompareLegacyMidPoint(){

//        let testTurbine = getEggelsSomersConfig(gridx: 300, uav: 0.1, impellerStartupStepsUntilNormalSpeed: 0, startingStep: 0, impellerStartAngle: 0)
//
//        let Legacy = getGeometryGillersion(turbine: testTurbine)
//        let midpoint = getMidPointGeometry(turbine: testTurbine)
//
//        XCTAssertEqual(Legacy, midpoint)



    }












    func testSampleTurbineConfig(){



        let TurbineES = getEggelsSomersConfig(gridx: 300, uav: 0.1, impellerStartupStepsUntilNormalSpeed: 0, startingStep: 0, impellerStartAngle: 0)

        XCTAssertEqual(TurbineES.tankDiameter, 298)
        XCTAssertEqual(TurbineES.numImpellers, 1)
        XCTAssertEqual(TurbineES.impeller[0]!.blades.top, 188)


        let TurbineGUIDemo = getGUIDemoJson()
        XCTAssertEqual(TurbineGUIDemo.tankDiameter, 300)
        XCTAssertEqual(TurbineGUIDemo.numImpellers, 3)
        XCTAssertEqual(TurbineGUIDemo.impeller[0]!.blades.top, 240)
        XCTAssertEqual(TurbineGUIDemo.impeller[1]!.blades.top, 20)



        //        turbines.append(getLegacy(gridx: <#T##Int#>, uav: <#T##Double#>, impellerStartupStepsUntilNormalSpeed: <#T##Int#>, startingStep: <#T##Int#>, impellerStartAngle: <#T##Double#>))




    }



    static var allTests = [
        ("testMidPointGeometry", testMidPointGeometry),
        ("testGeometryLegacy", testGeometryLegacy),
        ("testSampleTurbineConfig", testSampleTurbineConfig),
    ]




}
