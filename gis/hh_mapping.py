import arcpy
import os


arcpy.env.overwriteOutput=True

arcpy.env.workspace = "Z:/Dropbox/data/LEAPS/data/Constructed/ethnic_info/gis/"


# Target geodatabase name -- delete if it fails up front!
Output="ethnic_gis.mdb"
try:
    arcpy.Delete_management(Output,"Workspace")
    print "Deleted Old Database"
except:
    # Output.gdb did not exist, pass
    print "Did not delete"
    pass
arcpy.CreatePersonalGDB_management(arcpy.env.workspace, Output, "CURRENT")
print "Created New Database"


arcpy.MakeXYEventLayer_management("hhgps.txt","hh_gps_east","hh_gps_north","temp","GEOGCS['GCS_WGS_1984',DATUM['D_WGS_1984',SPHEROID['WGS_1984',6378137.0,298.257223563]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]];-400 -400 1000000000;-100000 10000;-100000 10000;8.98315284119521E-09;0.001;0.001;IsHighPrecision","#")

arcpy.CopyFeatures_management("temp", "ethnic_gis.mdb/hhs")

print "Done!"

