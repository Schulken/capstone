FROM nginx:alpine 

LABEL maintainer="andre.schulke@bertelsmann.de"
##MAINTAINER Andre Schulke <andre.schulke@bertelsmann.de>

# Copy source code to working directory
COPY index.html /usr/share/nginx/html/index.html 

# Expose port 80
EXPOSE 80 

CMD ["nginx", "-g" , "daemon off;"] 
