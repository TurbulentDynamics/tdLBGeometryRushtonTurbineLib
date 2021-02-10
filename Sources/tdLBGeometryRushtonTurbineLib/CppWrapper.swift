//
//  SwiftWrapper.swift
//  
//
//  Created by Vedran Ozir on 19.01.2021..
//

import Foundation
import tdLBGeometryRushtonTurbineLibObjC

public struct RushtonTurbineMidPointCPP {

    var tdLBGeometryRushtonTurbineLibObjC_inst: tdLBGeometryRushtonTurbineLibObjC?
    
    public init(rushtonTurbine: RushtonTurbineCPP, extents: ExtentsCPP) {
        
        tdLBGeometryRushtonTurbineLibObjC_inst = tdLBGeometryRushtonTurbineLibObjC(rushtonTurbine.rushtonTurbineObjC_inst!, ext: extents.extentsObjC_inst!)
    }
    
    public func generateFixedGeometry() {
        
        tdLBGeometryRushtonTurbineLibObjC_inst?.generateFixedGeometry()
    }
    
    public func generateRotatingGeometryNonUpdating() {
        
        tdLBGeometryRushtonTurbineLibObjC_inst?.generateRotatingGeometryNonUpdating()
    }
    
    public func generateRotatingGeometry(atTheta: Double) {
    
        tdLBGeometryRushtonTurbineLibObjC_inst?.generateRotatingGeometry(atTheta)
    }
    
    public func updateRotatingGeometry(atTheta: Double) {
    
        tdLBGeometryRushtonTurbineLibObjC_inst?.updateRotatingGeometry(atTheta)
    }


    public func returnFixedGeometry() -> [Pos3d_int] {

        if let tdLBGeometryRushtonTurbineLibObjC_inst = tdLBGeometryRushtonTurbineLibObjC_inst {
            return tdLBGeometryRushtonTurbineLibObjC_inst.returnFixedGeometry()
        } else {
            return []
        }
    }

    public func returnRotatingNonUpdatingGeometry() -> [Pos3d_int] {

        if let tdLBGeometryRushtonTurbineLibObjC_inst = tdLBGeometryRushtonTurbineLibObjC_inst {
            return tdLBGeometryRushtonTurbineLibObjC_inst.returnRotatingGeometryNonUpdating()
        } else {
            return []
        }
    }

    public func returnRotatingGeometry() -> [Pos3d_int] {

        if let tdLBGeometryRushtonTurbineLibObjC_inst = tdLBGeometryRushtonTurbineLibObjC_inst {
            return tdLBGeometryRushtonTurbineLibObjC_inst.returnRotatingGeometry()
        } else {
            return []
        }
    }


}

public struct RushtonTurbineCPP {

    var rushtonTurbineObjC_inst: RushtonTurbineObjC?
    
    public init() {
        
        rushtonTurbineObjC_inst = RushtonTurbineObjC()
    }
    
}

public struct ExtentsCPP {

    var extentsObjC_inst: ExtentsObjC?
    
    public init() {
        
        extentsObjC_inst = ExtentsObjC()
    }
    
}
