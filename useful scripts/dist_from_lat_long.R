LL_dist = function(lat1,lon1,lat2,lon2) { 
  R = 3961
  pi180 = pi/180
  dlon = ((lon2*pi180) - (lon1*pi180))
  dlat = ((lat2*pi180) - (lat1*pi180)) 
  a = (sin(dlat/2))^2 + cos((lat1*pi180)) * cos((lat2*pi180)) * (sin(dlon/2))^2 
  c = 2 * atan2( sqrt(a), sqrt(1-a) ) 
  d = R * c # (where R is the radius of the Earth)
  return(d)
}

#new york => 40.7128° N, 74.0059° W
#phili => 39.9526° N, 75.1652° W

la1 = 40.7128
lo1 = -74.0059
la2 = 39.9526
lo2 = -75.1652

LL_dist(la1,lo1,la2,lo2)

data_com = data.frame(ID=paste("C",c(1:100),sep=""),Value=rnorm(100,20,5),latitude=runif(100,39.5,40),longitude=runif(100,75,75.5))
head(data_com)

mat_com = as.matrix(data_com[,2:4])
for (i in 1:nrow(mat_com)) {
  mile_r_vals = c()
  
  
  
}