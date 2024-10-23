# Latency based forwarder for the Grid Dashboard

Threefold hosts 5 individual full [Grid backend stacks](https://github.com/threefoldtech/grid_deployment/tree/development/docker-compose):
- DE: https://dashboard.grid.tf
- US: https://dashboard.us.grid.tf
- BE: https://dashboard.be.grid.tf
- SG: https://dashboard.sg.grid.tf
- FIN: https://dashboard.fin.grid.tf

`index.html` contains a small latency test to these endpoints, it will forward a browser request to the stack that replies first from the user's perspective.

This will only work for browsers and for a forward to the dashboard, not other Grid backend services like Graphql, Gridproxy or Relay.

It can be exposed without extra configuration by any webserver. Caddy example:

```sh
dashboard.geo.grid.tf {
        # Set this path to your site's directory.
        root * /usr/share/caddy

        # Enable the static file server.
        file_server
}
```
