# CDRex

![**CDRex**](CDRex.png)

**CDRex** is an Elixir API that keeps track and calcutate the billable amounts of Voice call Detail Records (CDR) based on rates charged by carriers and fees charged from customers for different service types.

## Installation
### Docker
If you have docker installed just run:

```
docker-compose -f docker-compose.dev.yml up
```

### Asdf

If you don't have Elixir and Erlang installed, you can install both via asdf.
In order to install asdf please follow the instructions in the
[asdf documentation page](http://asdf-vm.com/guide/getting-started.html#_1-install-dependencies).

With `asdf` installed, please enter this commands on your terminal to install the required plugins:

```
asdf plugin-add erlang
asdf plugin-add elixir
```

Then, install the required versions of Erlang and Elixir with:

```
asdf install erlang 24.0.1
asdf install elixir 1.13.2
```

You will also need Postgres installed. You can find installation guides for the main OSs in the [postgres download page](https://www.postgresql.org/download/).

With Erlang, Elixir and Postgres installed, go to the repository folder and type:

```
mix deps.get
mix ecto.setup
```

After installing the dependencies and setting up the DB, just type the following command to start the server.

```
mix phx.server
```

## Usage

Once the server is running the endpoints will be available on `localhost:4000`.

The firs time you start **CDRex** it will parse and persist the carrier rates, client fees and CDRs provided by the CSV files in `priv/assets`. It will also calculate the billing amount for each CDR based on on the data from carriers and clients. **CDRex** keeps track of all imported CSVs by persisting the `SHA256` hash of the file in order to avoid unecessary re-imports. If you restart **CDRex** it will only import modified files.

**CDRex** have two endpoints:

- ### `POST /api/v1/cdrs`

Use this endpoint to post new CDRs. **CDRex** will calculate its billable amount as soon as it is imported. The body of the requisition should have the following params:

```json
{
  "carrier_name": "Carrier Name",
  "client_code": "CLIENTCODE",
  "client_name": "Client Name",
  "destination_number": "123456789",
  "direction": "outbound",
  "number_of_units": "10",
  "service": "voice",
  "source_number": "987654321",
  "success": "true"
}
```

A timestamp will be assigned at the moment of the post and the amount will be calculated. If the client or the carrier does't exist an error will be returned.

- ### `GET /api/v1/cdrs/client_summary_by_month`

This endpoint returns a summary report of amounts to be charged from a particular client in a particular month. The following query params should be appended to the URL: `client_code`, `month` and `year`.

To exemplify, the following query should return the total amount to be charged per service type for the client `CLIENTCODE`.

`GET /api/v1/cdrs/client_summary_by_month?client_code=CLIENTCODE&month=1&year=2022`

The return will have the following structure:

```json
  {
    "data": {
        "service_1": {
            "count": 1,
            "total_price": 1.5
        },
        "service_2": {
            "count": 1,
            "total_price": 1.5
        },
        "service_3": {
            "count": 1,
            "total_price": 1.5
        },
        "total": {
            "count": 3,
            "total_price": 4.5
        }
    }
}
```

## Running Tests

If you are using Docker, just enter:

```
docker-compose -f docker-compose.dev.yml run -e "MIX_ENV=test" api-dev mix test
```

If you have Elixir installed:

```
mix test
```

## Bonus!

**CDRex** can import new CDRs from a CSV file. Files previously imported will be ignored. If a file contains CDRs already imported **CDRex** will update them.

- ### `POST /api/v1/cdrs/import`

#### Body:

```json
{
    "file": binary_file
}
```