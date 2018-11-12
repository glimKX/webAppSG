# FunQ WebApp

Web Application for testing q functions base on csv inputs (FunQ)

## Getting Started

Clone the entire repo and set up the environment in config/env.config and config/port.config

### Prerequisites

These are required for the application to run

```
kdb+/q
unix environment
apache2 for webhosting

```

### Overview of scripts

No deployment as these are just scripts
Just requires the structure to be intact

```
scripts
|_______heartbeat.q(heartbeat to restart process)
|_______cron.q(cron/timer capability)
|_______log.q(logging)
|_______perm.q(permissioning)
|_______tick(application name)
	|____________________________test.q (test processes to run testCases)
	|____________________________backend.q (backend process, central node of connections internally, handles jobs dispatching with test processes)
	|____________________________gateway.q (gateway process, central node of connections externally, handles jobs with clients)
```

## Starting the application

Set up configurations and q
run ./main.sh
```
1 to start processes, use 1 for the right workflow
2 to shutdown processes, use 1 to just kill all, specific number for testing purpose
3 to display processes running with pid, ports, arg, and scripts used
```
create a symlink in /var/www to point to the html folder in this repo

### Using the application

To start the webapp, go to your ipaddress and the webpage should load

Login Page
```
- Ensure that the user has been created in the backend
- Enter username and password to load funQ portal abb
```
funQPortal
```
- Page requires csv upload which in the repo to set up testcases (kdb formatting is required, such as list and ";")
- Page requires schema for testing to be set up properly (Int/String/Symbol)
```

## Built With

* [jQuery]() - jQuery which is present in the front end scripts
* [Datatable]() - Used to create tables for display in H5
* [Bootstrap]() - Used to create H5 File


## Authors

* **Guan Yu** - *Initial Contribution* - [glimKx](https://github.com/glimkx)
* **Hai Ming** - *Perm.q Contribution* 
* **Daryl Lee** - *ChatRoom Contribution* - [valleyfresh](https://github.com/valleyfresh)
