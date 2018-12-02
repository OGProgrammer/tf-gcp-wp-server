# Terraform Module for a GCP WordPress Instance

A basic Terraform module that builds a Debian 9 GCP instance, grabs a static ip, and puts it into your VPC via a public subnetwork you provide.

## How it works
The `wp-server-deb9.sh` script will attempt to provision your server. Always ssh in after to review how the initialization process went.

You will need to upload some files to this server to add new wordpress sites. This setup allows you to install as many sites as the instance can handle on the server.

Note this is not a load balanced solution and is meant for basic site traffic.

My intent it to make an affordable way to host many WordPress sites on a single GCP instance.

## Installation

See example `./example-tf-apply.sh` script in this repo to review how to programmatically sync the template files and scripts to your new instance(s).

It uses the `terraform output` & `jq` to push the instance names into the `gcloud compute scp` command to sync these files.

### What to put in your Terraform

Put the module and the outputs for this all to work well.

#### How to include the Terraform Module

```HCL
module "srv1" {
# Required Vars
  source = "git@github.com:ogprogrammer/tf-gcp-wp-server.git"
  subnetwork = "${google_compute_subnetwork.some_public_subnet.name}"
  region = "us-central1"
  zone = "a"
  vendor = "ogp"
  server-tag = "01"
  
# Optional Vars
  protect-from-deletion = "true"
  machine-type = "n1-standard-1"
  env = "prod"
}
```

#### Outputs for the tf-apply.sh script

```HCL
output "server_ips" {
  value = [
    "${module.srv1.server_ip}",
    "${module.srv2.server_ip}"
  ]
}

output "server_names" {
  value = [
    "${module.srv1.server_name}",
    "${module.srv2.server_name}"
  ]
}
```

### Creating new WordPress sites on your instance

SSH into your instance with the server name + zone like so:

`gcloud compute ssh tf-ogp-wp-01 --zone us-central1-a`

Once you are on the instance, `cd` to the `./files` directory in your users home directory.

Run the script like this to create a new wordpress site on the instance: `./new-wp-site example example.com`

## Notes

* Why not ee?
  * I tried it and it is locked to Ubuntu. I'm a fan of Debian for prod systems.
* Why Bash and not SaltStack, Chef, Puppet, etc.
  * Cause I didnt want to add more overhead but feel free to fork or contribute.
* Why not use the terraform file provisioner for the files that need to be synced?
  * I had issues with it destroying/creating instances when the files changed. This behavior can be seen if the provision script changes. I need to find a way to ignore that
* Why not use docker/kubernetes?
  * Tried and isn't very Terraform friendly. If you are doing this with Terraform somehow, hit me up.
  
### Caching

This is a really great resource for reading on Varnish + Redis. I'd like to ensure the sites work as fast as possible so I'm putting this here to review later.

https://pantheon.io/wordpress/cache-plugins


## ToDos

Add the zone bash var in the tf-apply script so it not hardcoded to central.

## License

[MIT](https://opensource.org/licenses/MIT)