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
    
    public func generateRotatingNonUpdatingGeometry() {
        
        tdLBGeometryRushtonTurbineLibObjC_inst?.generateRotatingNonUpdatingGeometry()
    }
    
    public func generateRotatingGeometry(atTheta: Double) {
    
        tdLBGeometryRushtonTurbineLibObjC_inst?.generateRotatingGeometry(atTheta)
    }
    
    public func updateRotatingGeometry(atTheta: Double) {
    
        tdLBGeometryRushtonTurbineLibObjC_inst?.updateRotatingGeometry(atTheta)
    }


//    public func returnFixedGeometry() -> [Pos3d] {
    public func returnFixedGeometry() -> [Pos3d_int] {

        if let tdLBGeometryRushtonTurbineLibObjC_inst = tdLBGeometryRushtonTurbineLibObjC_inst {
            
            let pts = tdLBGeometryRushtonTurbineLibObjC_inst.returnFixedGeometry()
            
//            return pts.map{Pos3d($0.i, $0.j, $0.k}
            
            return pts
        } else {
            return []
        }
    }

    public func returnRotatingNonUpdatingGeometry() -> [Pos3d_int] {

        if let tdLBGeometryRushtonTurbineLibObjC_inst = tdLBGeometryRushtonTurbineLibObjC_inst {
            return tdLBGeometryRushtonTurbineLibObjC_inst.returnRotatingNonUpdatingGeometry()
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
    
    public init(x0: Int, x1:Int, y0: Int, y1:Int, z0: Int, z1:Int) {
        
        self.extentsObjC_inst = ExtentsObjC(Int32(x0), x1: Int32(x1), y0: Int32(y0), y1: Int32(y1), z0: Int32(z0), z1: Int32(z1))
    }
    
}
