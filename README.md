# Resample geolocated data to a grid

## About
This algorithm takes a geolocated dataset, where points have a set of coordinates (longitude and latitude) and an associated value,
and resample the data on a regular grid of latitude and longitude. The goal is to 'spread' the values of the points on a regular grid.

By default the grid generated is rectangular.
If a shapefile of the boundaries is provided, the grid will follow the country borders.

## R, libraries, options
### Why R
I wrote this algorithm in R and the only reason for it is that I wanted to try it in R. It's not about writing the fastest and most efficient algorithm, but rather see what I could do to solve this problem.

### Libraries
I run this in R studio and I need *sp*, *rgdal*, and *rgeos* libraries to geocode latitude and longitude data.
*dplyr* is here for aggregation but you can also use basic aggregation from R.
*ggplot2* , *maps*, *map_data* are here only if you want to plot the resulted grid.

### What else you could do with it
Although I am geocoding the coordinates, I use cartesian distances. To change this you can add options in the *gDistance* function  (rgeos), and pick another way.


## Algorithm
### About
I named *value points* the original dataset, that holds coordinates and the value of the points. *grid points* are the points on the grid.
I need to find the value of each grid point.

### Rules
1. The value of each grid point is affected only by the closest value point, not by the rest of the value points.

2. The value of a grid point should depend on the squared distance to the value point it is affected by.
The closer the grid point is to the value point, the bigger its 'share' of the original value is.
The farther the grid point is to the value, the smaller its share of the original value is.

3. The value of the value point should be spread among the grid points that are the closest to it. That means that if you would sum
the value of all the grid point around a value point, the result would be the original value of the value point. That also means that the value
to assign to a grid point needs to be ponderated by a constant, which is the sum of the inverse of the (squared or not) distances from the value point
to all its closest grid points.

## Squared or not squared distances ?
Using squared distances will result in having your values spread 'rapidly' around the original point, so that the grid values are rapidly small.
Using 'normal' distances will result in having the values spread on a bigger area around the original point.
It all depends if you want to have higher density of value around the original point or not. There is a boolean paramater in `generateGridValues` that allows you to choose the method you wish!


## How to use it
Assuming you loaded a data frame called *data*, run: `generateGridValues(data, 'Latitude', 'Longitude', 'Value', step, useSquaredDistances, polygon)` where

- *data* is the data frame
- 'Latitude' is a string containing the column name of the latitude in *data*
- 'Longitude' is a string containing the column name of the longitude in *data*
- 'Value' is a string containing the column name of the values you want to resample in *data*
- step is a number indicating the grid step (the smaller, the densier is the grid and also the longer is the execution time)
- useSquaredDistances is a boolean indicating, if TRUE that you want to use squared distances or not in the computation.
- polygon is a SpatialPolygonsDataFrame containing the boundaries of the area you want to generate your grid upon.
polygon is an optional argument. If it is left empty, the grid generated will be rectangulare. If you provide a polygon (via readShapefile, see the example), then the grid will take into account the borders of the area, and only grid points that are inside the polygon will be used.

## Example
Source of the data : http://www.geonames.org/NL/largest-cities-in-netherlands.html
It plots the population of the biggest city on the Netherlands.

Original Data :

![Population in the biggest city of Netherlands](https://github.com/agatheblues/r-resample-geodata-to-grid/blob/master/example/nl_map_original.png)

Generated grid if you provide a polygon :
![Grid of the population in the biggest city of Netherlands, with grid points in polygon only](https://github.com/agatheblues/r-resample-geodata-to-grid/blob/master/example/nl_inPolygon.png)


Generated grid if you don't provide a polygon :

![Grid of the population in the biggest city of Netherlands](https://github.com/agatheblues/r-resample-geodata-to-grid/blob/master/example/nl_map_grid.png)

Plotted in QGIS :

![Grid of the population in the biggest city of Netherlands plotted in qgis](https://github.com/agatheblues/r-resample-geodata-to-grid/blob/master/example/nl_map_grid_wqgis.png)


## Limitations
- I tested this on small datasets (~600 records) or small regions (~city size).
