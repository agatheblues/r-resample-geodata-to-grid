# Resample geolocated data to a grid

## About
This algorithm takes a geolocated dataset, where points have a set of coordinates (longitude and latitude) and an associated value,
and resample the data on a regular grid of latitude and longitude. The goal is to 'spread' the value of a point on the grid.

## Algorithm
I named *value points* the original dataset, that holds coordinates and the value of the points. *grid points* are the points on the grid.
I need to find the value of each grid point.

Rules :
1. The value of each grid point is affected only by the closest value point, not by the rest of the value points.

2. The value of a grid point should depend on the sqaured distance to the value point it is affected by.
The closer the grid point is to the value point, the bigger its 'share' of the original value is.
The farther the grid point is to the value, the smaller its share of the original value is.

3. The value of the value point should be spread among the grid points that are the closest to it. That means that if you would sum
the value of all the grid point around a value point, the result would be the original value of the value point. That also means that the value
to assign to a grid point needs to be ponderated by a constant, which is the sum of the inverse of the squared distances from the value point
to all its closest grid points.
