# WIMS-LTI

This docker image contains [WIMS-LTI](https://github.com/PremierLangage/wims-lti/), a gateway server that links [LMSs](https://en.wikipedia.org/wiki/Learning_management_system) to [WIMS](https://wiki.wimsedu.info/) servers, using [LTI](https://en.wikipedia.org/wiki/Learning_Tools_Interoperability).

A volume is created, containing both the configuration file `config.py` and the SQLite database `db.sqlite3`, so that they persist after upgrades. However, I suspect this may not work when the upgrade involves the upstream version of WIMS-LTI. It seems that WIMS-LTI executes the migration script only during installation, which is performed during image creation, i.e., too early to be useful.

In general, this image has only been developed for my personal needs, so be careful when using it. A better and more general image will be provided in the future.

## Example deployment

This an example of `docker-compose.yml` usable for deployment of the image trough Docker Compose, behind a reverse proxy.

```yaml
version: '3.2'

volumes:
  data:

services:
  app:
    image: amatogianluca/wims-lti
    hostname: wims-lti
    restart: always
    volumes:
      - data:/wims-lti/data:Z
    ports:
      - 127.0.0.1:10000:80
```

In the example above, the HTTP port of the container is exported as port 10000 in localhost. 

### Expose under the `/wims-lti` subpath

The following Apache config file may be used to expose WIMS-LTI behind the `/wims-lti` subpath:

 ```apache
 <Location /wims-lti>
  ProxyPass http://127.0.0.1:10000
  ProxyPassReverse http://127.0.0.1:10000
  ProxyPreserveHost On
  RequestHeader set X-Forwarded-Proto https
</Location>
```

Note the use of `RequestHeader set X-Forwarded-Proto https` to make WIMS believe to be operating in HTTPS, even if the internal connection between the proxy and the WIMS server is HTTP. Obviously, the host must use HTTPS with the external world for the previous snippet to work.

In order to inform WIMS-LTI that it is operating in the `/wims-lti` subpath, and that it needs to check the `X-Forward-Proto` HTTP header, the following lines must be added to `config.py`.

```python
# This is required when WIMS-LTI is deployed in a subpath
FORCE_SCRIPT_NAME = '/wims-lti'

# This is required to override the absolute /static/ setting in the configuration
STATIC_URL = 'static/'

# Environment variable used to check if proxying trough https
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
```
