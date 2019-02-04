# docker-pimcore-ecommerce
Docker container for Pimcore ecommerce app (fully featured Pimcore5 demo-ecommerce installation).

## Building locally 
```
git clone https://github.com/neshikj/docker-pimcore-ecommerce.git docker-pimcore-ecommerce
cd docker-pimcore-ecommerce
docker build -t pim/ecommerce . 
docker run -ti -d -p 8081:80 -v "$PWD/app":/var/www/app -v "$PWD/src":/var/www/src -v "$PWD/web/var":/var/www/web/var --name=pimecommerce pim/ecommerce
```

## Running pimcore
After starting the container it'll take some time until your pimcore installation is ready. This depends on your internet connection as well as on the available ressources on the host. 

You can check the status of your image at any time by using the following command: 
```
docker logs -f pimecommerce
```

This image automatically exposes port 80 to the host, so after running the image you should be able to access the demo site via: 
```
http://localhost:8081
http://localhost:8081/admin
```

## Admin credentials

```
username: admin
password: demo
```
