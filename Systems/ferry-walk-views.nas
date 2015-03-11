###############################################################################
##
## Walk view configuration for Lodi or Tabor ferry for FlightGear
##
##  Copyright (C) 2010  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license v2 or later.
##
###############################################################################

# Constraints
var flycoDeck =
    walkview.makeUnionConstraint(
        [
         walkview.SlopingYAlignedPlane.new([-106.742, -19.19, 8.43],
                                           [106.0, 19.0, 8.43]),

        ]);

# Create the view managers.
var goofer_walker = walkview.Walker.new("Flightdeck Officer View", flycoDeck);
