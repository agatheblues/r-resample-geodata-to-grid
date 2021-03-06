library(ggplot2)
library(mapdata)
library(maps)
source('../resampleGeo.R')

## EXAMPLE WITHOUT PROVIDING A SHAPEFILE (POLYGON)
data_0 <- read.csv('NL_populationByCity.csv')
grid_sum <- generateGridValues(data_0, 'Latitude', 'Longitude', 'Population', 0.05, TRUE)

# Source for plotting the map script https://sarahleejane.github.io/learning/r/2014/09/21/plotting-data-points-on-maps-with-r.html
world <- map_data("world")
nl_data <- subset(world, world$region=="Netherlands")

p <- ggplot() + coord_fixed() + xlab("") + ylab("")
cleanup <- theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_rect(fill = 'white', colour = 'white'), axis.line = element_line(colour = "white"), legend.position="none", axis.ticks=element_blank(), axis.text.x=element_blank(), axis.text.y=element_blank())

nl_plot <- p + geom_polygon(data=nl_data, aes(x=long, y=lat, group=group), colour="light gray", fill=NA) + cleanup

# PLot original points
ori <- nl_plot + geom_point(data=data_0, aes(x=Longitude, y=Latitude, size=Population), colour="blue1", fill="blue1",pch=21, alpha=I(0.3)) + scale_size_area()
ori

# Plot netherlands map, original points in blue and grid in red
both <- nl_plot + geom_point(data=data_0, aes(x=Longitude, y=Latitude, size=Population), colour="blue1", fill="blue1",pch=21, alpha=I(0.3)) +
geom_point(data=grid_sum, aes(x=glon, y=glat, size=gridValue), colour="brown2", fill="brown2",pch=21, alpha=I(0.5)) +
scale_size_area()
both

# Plot only the grid
grid <- nl_plot + geom_point(data=grid_sum, aes(x=glon, y=glat, size=gridValue), colour="brown2", fill="brown2",pch=21, alpha=I(0.5)) + scale_size_area()
grid


## EXAMPLE WITH A POLYGON
# Get polygon world data
world_polygon <- readShapefile('nl_shapefile/ne_110m_admin_0_countries.shp', 'ne_110m_admin_0_countries')
# Filter on the netherlands
nl_polygon <- world_polygon[world_polygon$sov_a3 == 'NL1',]
# Run the command
grid_sum_inPolygon <- generateGridValues(data_0, 'Latitude', 'Longitude', 'Population', 0.05, TRUE, nl_polygon)
# Plot results
ggplot(data = nl_polygon) + geom_polygon(aes(x=long, y=lat), fill=NA, colour='black') + cleanup + geom_point(data=grid_sum_inPolygon, aes(x=glon, y=glat, size=gridValue), colour='red') + scale_size_area()


