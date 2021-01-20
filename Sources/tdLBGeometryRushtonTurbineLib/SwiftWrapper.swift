//
//  SwiftWrapper.swift
//  
//
//  Created by Vedran Ozir on 19.01.2021..
//

import Foundation
import tdLBGeometryRushtonTurbineLibObjC

public struct RushtonTurbineMidPointSwift {

    var tdLBGeometryRushtonTurbineLibObjC_inst: tdLBGeometryRushtonTurbineLibObjC?
    
    public init(rushtonTurbine: RushtonTurbineSwift, extents: ExtentsSwift) {
        
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
}

public struct RushtonTurbineSwift {

    var rushtonTurbineObjC_inst: RushtonTurbineObjC?
    
    public init() {
        
        rushtonTurbineObjC_inst = RushtonTurbineObjC()
    }
    
}

public struct ExtentsSwift {

    var extentsObjC_inst: ExtentsObjC?
    
    public init() {
        
        extentsObjC_inst = ExtentsObjC()
    }
    
}
