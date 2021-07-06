cc_library(
    name = "rtjson",
    srcs = ["jsoncpp.cpp"],
    hdrs = ["json.h"]
)

cc_library(
    name = "tdLBGeometryRushtonTurbineLib",
    hdrs = ["GeomMidPoint.hpp", "GeomPolar.hpp", "GlobalStructures.hpp", "RushtonTurbine.hpp"],
    deps = [":rtjson"],
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "test-polar",
    srcs = ["test-polar.cpp"],
    deps = [":rtjson",
            ":tdLBGeometryRushtonTurbineLib"],
)

