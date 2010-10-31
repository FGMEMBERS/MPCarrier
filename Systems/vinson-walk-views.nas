###############################################################################
##
## Walk view configuration for Nimitz or Vinson carrier for FlightGear
##
##  Copyright (C) 2010  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license v2 or later.
##100.178	33.9336	-24.4142
#119.546	33.9336	-33.5094
#
#99.7777	33.9336	-25.0142
#110.146	33.9336	-25.0142
#110.146	33.9336	-25.6094
#99.7777	33.9336	-25.6094
#
#110.146	33.9336	-25.6912
#110.894	33.9336	-25.6912
#110.894	33.9336	-25.1142
#110.146	33.9336	-25.1142
#
#110.896	33.9336	-25.2231
#111.645	33.9336	-25.2231
#111.645	33.9336	-25.8002
#110.896	33.9336	-25.8002
#
#111.652	33.9336	-25.9418
#112.4	33.9336	-25.9418
#112.4	33.9336	-25.3647
#111.652	33.9336	-25.3647
#
#112.407	33.9336	-25.5221
#113.155	33.9336	-25.5221
#113.155	33.9336	-26.0991
#112.407	33.9336	-26.0991
#
#113.162	33.9336	-26.2408
#113.911	33.9336	-26.2408
#113.911	33.9336	-25.6637
#113.162	33.9336	-25.6637
#
#113.918	33.9336	-25.8368
#114.666	33.9336	-25.8368
#114.666	33.9336	-26.4138
#113.918	33.9336	-26.4138
#
#114.673	33.9336	-26.5712
#115.421	33.9336	-26.5712
#115.421	33.9336	-25.9941
#114.673	33.9336	-25.9941
#
#115.412	33.9336	-26.1515
#116.161	33.9336	-26.1515
#116.161	33.9336	-26.7285
#115.412	33.9336	-26.7285
#
#116.183	33.9336	-26.9016
#116.932	33.9336	-26.9016
#116.932	33.9336	-26.3246
#116.183	33.9336	-26.3246
#
#116.939	33.9336	-26.4976
#117.687	33.9336	-26.4976
#117.687	33.9336	-27.0747
#116.939	33.9336	-27.0747
################################################################################

# Constraints
var flycoDeck =
    walkview.makeUnionConstraint(
        [
         walkview.slopingYAlignedPlane.new([99.7, 25.0, 33.7],
                                           [110.1, 25.6, 33.7]),
         walkview.slopingYAlignedPlane.new([110.1, 25.1, 33.7],
                                           [110.9, 25.7, 33.7]),
         walkview.slopingYAlignedPlane.new([110.9, 25.2, 33.7],
                                           [110.7, 25.8, 33.7]),
         walkview.slopingYAlignedPlane.new([110.7, 25.3, 33.7],
                                           [111.6, 25.9, 33.7]),
         walkview.slopingYAlignedPlane.new([111.6, 25.4, 33.7],
                                           [112.4, 26.0, 33.7]),
         walkview.slopingYAlignedPlane.new([112.4, 25.5, 33.7],
                                           [113.2, 26.1, 33.7]),
         walkview.slopingYAlignedPlane.new([113.2, 25.6, 33.7],
                                           [113.9, 26.2, 33.7]),
         walkview.slopingYAlignedPlane.new([113.9, 25.7, 33.7],
                                           [114.7, 26.3, 33.7]),
         walkview.slopingYAlignedPlane.new([114.7, 25.8, 33.7],
                                           [115.4, 26.4, 33.7]),
         walkview.slopingYAlignedPlane.new([115.4, 25.9, 33.7],
                                           [116.2, 26.5, 33.7]),
         walkview.slopingYAlignedPlane.new([116.2, 26.0, 33.7],
                                           [116.9, 26.6, 33.7]),
         walkview.slopingYAlignedPlane.new([116.9, 26.1, 33.7],
                                           [117.7, 26.7, 33.7]),
         walkview.slopingYAlignedPlane.new([117.45, 26.71, 33.7],
                                           [119.46, 33.21, 33.7]),
         walkview.slopingYAlignedPlane.new([105.79, 32.23, 33.7],
                                           [117.45, 33.21, 33.7]),

        ]);

var hangarDeck =
    walkview.makeUnionConstraint(
        [
         walkview.slopingYAlignedPlane.new([7.26949, -11.622, 9.4038],
                                           [188.003, 14.3373, 9.4038]),
        ]);

# Create the view managers.
var goofer_walker = walkview.walker.new("Goofers' View", flycoDeck);
var hangar_walker = walkview.walker.new("Hangar View", hangarDeck);

