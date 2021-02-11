//
//  SwiftWrapper.swift
//  
//
//  Created by Vedran Ozir on 19.01.2021..
//

import Foundation
import tdLB
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


    public func returnFixedGeometry() -> [Pos3d] {

        if let tdLBGeometryRushtonTurbineLibObjC_inst = tdLBGeometryRushtonTurbineLibObjC_inst {
            
            let pts = tdLBGeometryRushtonTurbineLibObjC_inst.returnFixedGeometry()
            return pts.map{Pos3d(i: Int($0.i), j:Int($0.j), k:Int($0.k))}
            
        } else {
            return []
        }
    }

    public func returnRotatingNonUpdatingGeometry() -> [Pos3d] {

        if let tdLBGeometryRushtonTurbineLibObjC_inst = tdLBGeometryRushtonTurbineLibObjC_inst {
            
            let pts = tdLBGeometryRushtonTurbineLibObjC_inst.returnRotatingNonUpdatingGeometry()
            return pts.map{Pos3d(i: Int($0.i), j:Int($0.j), k:Int($0.k))}

        } else {
            return []
        }
    }

    public func returnRotatingGeometry() -> [Pos3d] {

        if let tdLBGeometryRushtonTurbineLibObjC_inst = tdLBGeometryRushtonTurbineLibObjC_inst {
            let pts = tdLBGeometryRushtonTurbineLibObjC_inst.returnRotatingGeometry()
            return pts.map{Pos3d(i: Int($0.i), j:Int($0.j), k:Int($0.k))}

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
