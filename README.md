distiller
=========
This is the repository for Open Addresses' "Distiller" software component, part of the solution we deployed for the Alpha stage of our services.

This component extracts addresses from the [Ernest](https://github.com/OpenAddressesUK/ernest) master database, checks for duplicates, and matches address parts (towns, streets, localities and postcodes) to exact entities.

Read about our production setup [here](http://openaddressesuk.org/docs) or learn about Open Addresses in general [here](http://openaddressesuk.org).

## Dependencies

As well as Ruby version 2.1.3, you'll also need MongoDB installed. [See installation instructions](http://docs.mongodb.org/manual/installation/).

## Running

### Clone this repo:

    git clone git@github.com:OpenAddressesUK/distiller.git

### Bundle:

    bundle install

### Add a file called `.env` with the following contents:

    ERNEST_ADDRESS_ENDPOINT={URL for the list of addresses from the Ernest master database}

If you're hacking away on this, you can just use the master OpenAddresses master database at http://ernest.openaddressesuk.org/addresses

If you're running on production, you'll need to add the following too:

    MONGOLAB_URI: {The URI to access your production MongoDB database}
    HEROKU_TOKEN: {your Heroku API token - assuming you're running on Heroku}
    HEROKU_APP: {yout Herkou app name - assuming you're running on Heroku}

### Import the reference tables

    rake distiller:import:all

This imports all the towns, streets, localities and postcodes needed for the distil to run

### Run the distiller

    rake distiller:distil:all[start_index,step]

Where `start_index` is the page you want to start from, and `steps` is the number you want to step by after distilling each page of the Ernest API. This allows you to use multiple workers on, say, Heroku to make the distil quicker. See [our Procfile](https://github.com/OpenAddressesUK/distiller/blob/master/Procfile) for an example.

This will attempt to import all the (currently)  2,934,651 addresses in the master database, so you may want to go for a smaller sample size. Try:

    rake distiller:distil:pages[n]

Where `n` is the number of pages you would like to cycle through on the Ernest API (25 records per page)

If you already have some addresses in your database, and want to import any addresses that have been added since the last distil, run:

    rake distiller:distil:all

## Licence
This code is open source under the MIT license. See the [LICENSE.md](LICENSE.md) file for full details.
