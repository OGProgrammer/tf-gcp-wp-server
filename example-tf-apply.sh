#!/usr/bin/env bash
echo "REPOSITORY: tf-gcp-wp-server"
echo "SCRIPT: tf-apply.sh"
echo "EXECUTING: terraform apply"

echo "Checking for gcloud cli..."
if ! [ -x "$(command -v gcloud)" ]; then
    echo 'Error: gcloud cli is not installed.' >&2
    exit 1
fi

#Download plugins
terraform init

# Uncomment for verbose terraform output
#export TF_LOG=info

echo "terraform plan"
if terraform plan ; then
    echo "Terraform plan succeeded."
else
    echo 'Error: terraform plan failed.' >&2
    exit 1
fi

echo "terraform apply"
if terraform apply ; then
    echo "Terraform apply succeeded."
    echo "Uploading important files via gcloud"
    terraform output --json server_names | jq -rc '.value[]'  | while read serverName; do
        echo "Uploading files to server [$serverName]"
        until gcloud compute scp --recurse ./files/ $serverName:~/ --zone us-central1-a; do
            echo "Failed trying to upload files to your new google instance... Sleeping and retry in 10 seconds..."
            sleep 10
        done
        # do stuff with $i
    done
else
    echo 'Error: terraform apply failed.' >&2
    exit 1
fi

echo "Apply Completed!";