# Turbulent Dynamics Geometry Rushton Turbine Library

Produces the point cloud of a Rushton Turbine for the LB simulation



## Package Structure

![Package Structure](https://github.com/TurbulentDynamics/tdLBApi/blob/master/docs/Package-Structure.png)



## Testing


```
BAZEL_CXXOPTS="-std=c++14" bazel build --verbose_failures //Sources/tdLBGeometryRushtonTurbineLibCPP:main-test-polar
./bazel-bin/Sources/tdLBGeometryRushtonTurbineLibCPP/main-test-polar
#view test-polar.ply 
#view test-polar-exclude.ply 
```


