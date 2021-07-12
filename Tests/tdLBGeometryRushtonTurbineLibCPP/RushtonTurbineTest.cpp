//
//  RushtonTurbineTest.cpp
//  RushtonTurbineTest
//
//  Unit tests for RushtonTurbine
//

#include "gtest/gtest.h"

#include "Sources/tdLBGeometryRushtonTurbineLibCPP/RushtonTurbine.hpp"

class RushtonTurbineTest : public ::testing::Test
{
protected:
    std::string filename;

public:
    void fillImpeller(Impeller &impeller, int offset)
    {
        impeller.numBlades = offset;
        impeller.firstBladeOffset = offset + 1;
        impeller.uav = offset + 3;
        impeller.bladeTipAngularVelW0 = offset + 4;
        impeller.impellerPosition = offset + 5;
        impeller.blades.innerRadius = offset + 6;
        impeller.blades.outerRadius = offset + 7;
        impeller.blades.bottom = offset + 8;
        impeller.blades.top = offset + 9;
        impeller.blades.thickness = offset + 10;
        impeller.disk.radius = offset + 11;
        impeller.disk.bottom = offset + 12;
        impeller.disk.top = offset + 13;
        impeller.hub.radius = offset + 14;
        impeller.hub.bottom = offset + 15;
        impeller.hub.top = offset + 16;
    }
    void fillTestFixedParams(RushtonTurbine &rushtonTurbine)
    {
        rushtonTurbine.wa = 1;
        rushtonTurbine.startingStep = 2;
        rushtonTurbine.impellerStartAngle = 3;
        rushtonTurbine.impellerStartupStepsUntilNormalSpeed = 4;
        rushtonTurbine.resolution = 5;
        rushtonTurbine.tankDiameter = 6;
        Baffles baffles;
        baffles.numBaffles = 7;
        baffles.firstBaffleOffset = 8;
        baffles.innerRadius = 9;
        baffles.outerRadius = 10;
        baffles.thickness = 11;
        rushtonTurbine.baffles = baffles;
        std::vector<Impeller> impellers;
        for (int i = 0; i < 2; i++)
        {
            Impeller impeller;
            fillImpeller(impeller, 12 + i * 17);
            impellers.push_back(impeller);
        }
        rushtonTurbine.impellers = impellers;
        rushtonTurbine.numImpellers = impellers.size();
        Shaft shaft;
        shaft.radius = 12;
        shaft.bottom = 13;
        shaft.top = 14;
        rushtonTurbine.shaft = shaft;
    }
    void checkAllFields(Baffles &expected, Baffles &actual)
    {
        ASSERT_EQ(expected.numBaffles, actual.numBaffles) << "numBaffles field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.firstBaffleOffset, actual.firstBaffleOffset) << "firstBaffleOffset field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.innerRadius, actual.innerRadius) << "innerRadius field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.outerRadius, actual.outerRadius) << "outerRadius field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.thickness, actual.thickness) << "thickness field has a wrong value after being written to a file and then read";
    }
    void checkAllFields(Blades &expected, Blades &actual)
    {
        ASSERT_EQ(expected.innerRadius, actual.innerRadius) << "innerRadius field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.outerRadius, actual.outerRadius) << "outerRadius field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.bottom, actual.bottom) << "bottom field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.top, actual.top) << "top field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.thickness, actual.thickness) << "thickness field has a wrong value after being written to a file and then read";
    }
    void checkAllFields(Disk &expected, Disk &actual)
    {
        ASSERT_EQ(expected.radius, actual.radius) << "radius field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.bottom, actual.bottom) << "bottom field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.top, actual.top) << "top field has a wrong value after being written to a file and then read";
    }
    void checkAllFields(Impeller &expected, Impeller &actual)
    {
        ASSERT_EQ(expected.numBlades, actual.numBlades) << "numBlades field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.firstBladeOffset, actual.firstBladeOffset) << "firstBladeOffset field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.uav, actual.uav) << "uav field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.bladeTipAngularVelW0, actual.bladeTipAngularVelW0) << "bladeTipAngularVelW0 field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.impellerPosition, actual.impellerPosition) << "impellerPosition field has a wrong value after being written to a file and then read";
        checkAllFields(expected.blades, actual.blades);
        checkAllFields(expected.disk, actual.disk);
        checkAllFields(expected.hub, actual.hub);
    }
    void checkAllFields(Shaft &expected, Shaft &actual)
    {
        ASSERT_EQ(expected.radius, actual.radius) << "radius field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.bottom, actual.bottom) << "bottom field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.top, actual.top) << "top field has a wrong value after being written to a file and then read";
    }
    void checkAllFields(RushtonTurbine &expected, RushtonTurbine &actual)
    {
        ASSERT_EQ(expected.wa, actual.wa) << "wa field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.startingStep, actual.startingStep) << "startingStep field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.impellerStartAngle, actual.impellerStartAngle) << "impellerStartAngle field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.impellerStartupStepsUntilNormalSpeed, actual.impellerStartupStepsUntilNormalSpeed) << "impellerStartupStepsUntilNormalSpeed field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.resolution, actual.resolution) << "resolution field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.tankDiameter, actual.tankDiameter) << "tankDiameter field has a wrong value after being written to a file and then read";
        ASSERT_EQ(expected.numImpellers, actual.numImpellers) << "numImpellers field has a wrong value after being written to a file and then read";
        checkAllFields(expected.baffles, actual.baffles);
        ASSERT_EQ(expected.impellers.size(), actual.impellers.size()) << "impellers field has a wrong size after being written to a file and then read";
        for (int i = 0; i < expected.impellers.size(); i++)
        {
            checkAllFields(expected.impellers[i], actual.impellers[i]);
        }
        checkAllFields(expected.shaft, actual.shaft);
    }

    std::string getTestName()
    {
        const testing::TestInfo *const test_info =
            testing::UnitTest::GetInstance()->current_test_info();
        return test_info->name();
    }
    RushtonTurbineTest()
    {
        filename = std::string(testing::TempDir()) + "/" + getTestName() + "_to_delete.json";
    }

    ~RushtonTurbineTest()
    {
        if (testing::Test::HasFailure())
        {
            std::ifstream src(filename, std::ios::binary);
            std::string globalName = "/tmp/" + getTestName() + "_to_delete.json";
            std::ofstream dst(globalName, std::ios::binary);
            dst << src.rdbuf();
            dst.close();
            src.close();
            std::cerr << "Copied temporary file to " << globalName << std::endl;
        }
    }
};

TEST_F(RushtonTurbineTest, RustonTurbineTestReadWriteValid)
{
    RushtonTurbine rushtonTurbine;
    fillTestFixedParams(rushtonTurbine);
    rushtonTurbine.saveGeometryConfigAsJSON(filename);
    RushtonTurbine rushtonTurbineRead;
    rushtonTurbineRead.loadGeometryConfigAsJSON(filename);
    checkAllFields(rushtonTurbine, rushtonTurbineRead);
}

TEST_F(RushtonTurbineTest, RustonTurbineTestReadWriteSetHartmannDerksenProportions)
{
    RushtonTurbine rushtonTurbine;
    rushtonTurbine.setHartmannDerksenProportions();
    rushtonTurbine.saveGeometryConfigAsJSON(filename);
    RushtonTurbine rushtonTurbineRead;
    rushtonTurbineRead.loadGeometryConfigAsJSON(filename);
    checkAllFields(rushtonTurbine, rushtonTurbineRead);
}

TEST_F(RushtonTurbineTest, RustonTurbineTestReadWriteSetGillissenProportions)
{
    RushtonTurbine rushtonTurbine;
    rushtonTurbine.setGillissenProportions();
    rushtonTurbine.saveGeometryConfigAsJSON(filename);
    RushtonTurbine rushtonTurbineRead;
    rushtonTurbineRead.loadGeometryConfigAsJSON(filename);
    checkAllFields(rushtonTurbine, rushtonTurbineRead);
}
