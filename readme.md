# netbox-rest-module-demo

This is a set of scripts to use with my netbox-rest-module project. Do not use this against a production netbox instance as it will generate a bunch of junk and place it into your netbox instance.

I'm currently using this project as a sort of test case to make sure that the actual powershell module works as expected.

The `add-sample.data.ps1` script will run all of the functions required to create a demo netbox install, in roughly the correct sequence. The `sample-data-functions.ps1` script contains all of the functions to process the sample data under `.\sample-data`.

This project will evolve over time and is currently at a "pretty good" state. It'll create a reasonably complete set of sample data and serve as an effective demo of how to use the `netbox-rest-module` project.

## Procedure

1. Install netbox somewhere.
2. Add a read-write API key to your account in netbox
3. You can just run `install-module netbox-rest-module -scope currentuser`
4. Download this project anywhere.
5. If you want to initialize the connection to your netbox instance, you can run `init.ps1` and it'll ask a few questions and store your API key in a secret vault.
6. Run `.\add-sample-data\add-sample-data.ps1` after making any changes to the source data csvs or function code you like.
7. Enjoy your demo instance of netbox.

