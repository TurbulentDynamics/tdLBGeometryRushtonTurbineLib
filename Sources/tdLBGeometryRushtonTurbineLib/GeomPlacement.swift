//
//  GeomPlacement.swift
//
//
//  Created by Claude on 2025.
//

import Foundation

/// Specifies where geometry points should be placed relative to solid boundaries.
///
/// This enum mirrors the C++ `GeomPlacement` enum in `GlobalStructures.hpp` and is used
/// to control whether geometry points are generated on surfaces, internally, or both.
///
/// - Note: For most Lattice Boltzmann simulations, `onSurface` is the appropriate choice
///   as it defines the boundary conditions at the fluid-solid interface.
public enum GeomPlacement: Int, CaseIterable, Sendable {
    /// Generate points only on the surface of geometry components.
    /// This is the default and most common option for LB boundary conditions.
    case onSurface = 0

    /// Generate points only inside the geometry (internal fill).
    case `internal` = 1

    /// Generate both surface and internal points.
    case surfaceAndInternal = 2

    /// Generate points outside the geometry (external region).
    case external = 3
}

/// Specifies the movement behavior of geometry components.
///
/// This enum mirrors the C++ `GeomMovement` enum in `GlobalStructures.hpp` and categorizes
/// geometry into different update strategies during simulation.
public enum GeomMovement: Int, CaseIterable, Sendable {
    /// Stationary geometry that never changes (e.g., tank walls, baffles).
    case fixed = 0

    /// Geometry that rotates and requires updating each timestep (e.g., impeller blades).
    case rotating = 1

    /// Geometry that rotates but doesn't need position updates (e.g., hub, disk, shaft).
    /// The velocity boundary conditions are set once at initialization.
    case rotatingNonUpdating = 2

    /// Geometry that translates linearly (not yet implemented).
    case translating = 3
}
