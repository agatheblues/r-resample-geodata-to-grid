# Resample geolocated data to a grid

## About
This algorithm takes a geolocated dataset, where points have a set of coordinates (longitude and latitude) and an associated value,
and resample the data on a regular grid of latitude and longitude. The goal is to 'spread' the values of the points on a regular grid.

## R, libraries, options
### Why R
I wrote this algorithm in R and the only reason for it is that I wanted to try it in R. It's not about writing the fastest and most efficient algorithm, but rather see what I could do to solve this problem.

### Libraries
I run this in R studio and I need *sp* and *rgeos* libraries to geocode latitude and longitude data.
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
to assign to a grid point needs to be ponderated by a constant, which is the sum of the inverse of the squared distances from the value point
to all its closest grid points.

## Example
Source of the data : http://www.geonames.org/NL/largest-cities-in-netherlands.html
It plots the population of the biggest city on the Netherlands.

Original Data :

![Population in the biggest city of Netherlands](https://github.com/agatheblues/r-resample-geodata-to-grid/blob/master/example/nl_map_original.png)

Generated grid :

![Grid of the population in the biggest city of Netherlands](https://github.com/agatheblues/r-resample-geodata-to-grid/blob/master/example/nl_map_grid.png)

Plotted in QGIS :

![Grid of the population in the biggest city of Netherlands plotted in qgis](https://github.com/agatheblues/r-resample-geodata-to-grid/blob/master/example/nl_map_grid_qgis.png)

## Limitations
- The generated grid does not follow country borders, it's a rectangular grid. So there are data points 'in the sea' or out of the country borders. 
- I tested this on small datasets (~600 records) or small regions (~city size).
