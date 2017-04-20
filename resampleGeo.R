setwd("~/Documents/Weather_Chart_2016/resampleGeo")
library(ggplot2)
library(sp)
library(rgeos)
library(dplyr)

## Rename latitude, longitude and value column
# df - data frame - Contains the latitude and longitude of the value points, and their attached value
# latName - string - String of the column name that contains the latitudes
# valueName - string - String of the column name that contains the values of the points
# RETURNS df - data frame - It's df with updated column names
setColumnNames <- function(df, latName, lonName, valueName) {
    names(df)[names(df) == latName] <- 'lat'
    names(df)[names(df) == lonName] <- 'lon'
    names(df)[names(df) == valueName] <- 'count'
    return(df)
}

## Genereate and Id column in the data frame df
# df - data frame
# colname - string - Name of the id column
# RETURNS - df_id - data frame - It's df with a new column named colname that contains an id for each row
generateIdColumn <- function(df, colname){
    id <- rownames(df)
    df_id <- cbind(id, df)
    colnames(df_id)[1] <- colname
    return(df_id)
}

## Generate a data frame containing the latitude and longitude of the grid points
# df - data frame - Contains the latitude and longitude of the value points
# step - double - Size of the grid step. The grid step is the distance between 2 grid points.
# RETURNS grid - data frame - Contains 2 columns glat and glon that respectively contains the latitude and the longitude of the grid points
getGrid <- function(df, step) {
    # Grid bounds
    minLat <- min(df$lat)
    maxLat <- max(df$lat)
    minLon <- min(df$lon)
    maxLon <- max(df$lon)

    if (maxLat-minLat < step || maxLon-minLon < step) {
        msg <- paste('\n The step is too big! \n The grid step must be smaller than the distance between the minimum and maximum latitudes:', maxLat-minLat, ', and minimum and maximum longitudes:', maxLon-minLon, sep=' ')
        stop(msg)
    }

    # Generate vector of possible latitudes
    latValues <- seq(minLat-step, maxLat+step, step)

    # Generate matrix of longitude values for each latitude
    lonValues <- sapply(latValues, function(latValues) seq(minLon-step, maxLon-step, step))

    # Sort longitude to have them grouped by value and make it a vector
    vector_lonValues <- sort(as.vector(lonValues))

    # Genereate the full vector of latitudes based on the length of the longitude vector
    length <- nrow(lonValues)
    vector_latValues <- rep(latValues, times=length)

    # Bind both vector together to get df of lat and lon
    grid <- data.frame(cbind(vector_latValues, vector_lonValues))
    colnames(grid) <- c('glat', 'glon')

    return(grid)
}

## Get pairwise distances between the grid points and the original points
# valuePoints - data frame - Contains the latitude and longitude of the value points
# gridPoints - data frame - Contains the latitude and longitude of the grid points
# RETURNS d - 2-dimensional matrix - d(i,j) is the distance between the coordinates of valuePoints at row i and the coordinates of gridPoints at row j
getDistances <- function(valuePoints, gridPoints) {
    # Geocode value points
    sp.valuePoints <- valuePoints
    coordinates(sp.valuePoints) <- ~lon+lat

    # Geocode grid points
    sp.gridPoints <- gridPoints
    coordinates(sp.gridPoints) <- ~glon+glat

    # Get distance between all points
    d <- gDistance(sp.valuePoints, sp.gridPoints, byid=TRUE)

    return(d)
}

## For each grid point, get the closest value point
# valuePoints - data frame - Contains the latitude and longitude of the value points
# gridPoints - data frame - Contains the latitude and longitude of the grid points
# RETURNS closest_points - data frame - Contains the grid points coordinates (glon, glat),
# the value point coordinates that is the closest to each of them (lat, lon)
# and the distance dist between the two points
getClosestPoint <- function(valuePoints, gridPoints) {
    d <- getDistances(valuePoints, gridPoints)

    # Get minimum distance per grid point and bind grid points, closest points and their distance together
    min.d <- apply(d, 1, function(x) order(x, decreasing=F)[1])
    closest_points <- cbind(gridPoints, valuePoints[min.d,], dist = apply(d, 1, function(x) sort(x, decreasing=F)[1]))

    return(closest_points)
}

# Get the sum of the inverse of the squared distances from a value point to all its neighbours grid points
# WRONG ! IT CALCULATES FOR ALL THE POINTS ATM
getInverseSquaredSumOfDistances <- function(closest_points){
    
    # Get inverse of squared value of each distance
    closest_points$inverseSquaredDist <- 1 / (closest_points$dist^2)
    
    df_sumInvSquaredDist <- closest_points[c('value_id', 'inverseSquaredDist')] %>% group_by(value_id) %>% summarise_each(funs(sumInvSquaredDist = sum))

    return(df_sumInvSquaredDist)
}

generateGridValues <- function(df, latName, lonName, valueName, step){
    df_0 <- setColumnNames(df, latName, lonName, valueName)
    df <- generateIdColumn(df_0, 'value_id')

    ## Generate grid points
    grid_0 <- getGrid(df, step)
    grid <- generateIdColumn(grid_0, 'grid_id')
    # qplot(glat, glon, data=grid)

    # Get closest value point to grid points
    grid_closest <- getClosestPoint(df, grid)

    # Get squared distance from value point to grid point
    grid_closest$squaredDist <- grid_closest$dist^2
     
    # Get sum of inverse suqred distances to the value point
    df_sumDistances <- getInverseSquaredSumOfDistances(grid_closest)

    # Merge closest and sum distances
    grid_sum <- merge(grid_closest, df_sumDistances, by='value_id')
    
    # Calculate the value of the grid point
    # It is the value of the closest value point, divided by the squared distance between the two points
    # and ponderated by the sum of the inverse squared distances of all the grid points that are closest to this
    # value point
    # CASE WHEN DIST = 0
    grid_sum$gridValue <- (grid_sum$count / grid_sum$squaredDist) * (1 / grid_sum$sumInvSquaredDist)

    return(grid_sum)
}

# Prepare dataset
data_0 <- read.csv('ny_station_count_start.csv')
grid_sum <- generateGridValues(data_0, 'lat', 'lon', 'Count', 0.002)

write.csv(grid_sum, 'ny_resample025_2.csv')

ggplot(grid_sum, aes(glat, glon)) + geom_point(aes(size=gridValue, alpha=0.2))
