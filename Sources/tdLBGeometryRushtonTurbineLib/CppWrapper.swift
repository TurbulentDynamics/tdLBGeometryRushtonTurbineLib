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
    
    public init(gridX: Int) {
        
        rushtonTurbineObjC_inst = RushtonTurbineObjC(Int32(gridX))
    }
    
}

public struct ExtentsCPP {

    var extentsObjC_inst: ExtentsObjC?
    
    public init(x1: Int, x2:Int, y1: Int, y2:Int, z1: Int, z2:Int) {
        
        self.extentsObjC_inst = ExtentsObjC(Int32(x1), x2: Int32(x2), y1: Int32(y1), y2: Int32(y2), z1: Int32(z1), z2: Int32(z2))
    }
    
}
