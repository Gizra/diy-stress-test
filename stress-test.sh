#!/bin/bash

LINODE_GROUP="stress-test"
NUMBER_OF_VISITORS="$1"

NUM_RE='^[0-9]+$'
if ! [[ $NUMBER_OF_VISITORS =~ $NUM_RE ]] ; then
  echo "error: Not a number: $NUMBER_OF_VISITORS" >&2; exit 1
fi

if (( $NUMBER_OF_VISITORS > 100 )); then
  echo "warning: Are you sure that you want to create $NUMBER_OF_VISITORS linodes?" >&2; exit 1
fi

echo "Reset the inventory file."
cat /dev/null > hosts

echo "Create the needed linodes, populate the inventory file."
for i in $(seq $NUMBER_OF_VISITORS);
do
  linode-cli linodes create --image "linode/ubuntu18.04" --region eu-central --authorized_keys "$(cat ~/.ssh/id_rsa.pub)" --root_pass "$(date +%s | sha256sum | base64 | head -c 32 ; echo)" --group "$LINODE_GROUP" --text --delimiter ";"
done

## Wait for boot.
while linode-cli linodes list --group="$LINODE_GROUP" --text --delimiter ";" --format 'status' --no-headers | grep -v running
do
  sleep 2
done

## Wait for the SSH port.
for IP in $(linode-cli linodes list --group="$LINODE_GROUP" --text --delimiter ";" --format 'ipv4' --no-headers);
do
  while ! nc -z $IP 22 < /dev/null > /dev/null 2>&1; do
    sleep 1
  done
  ### Collect the IP for the Ansible hosts file.
  echo "$IP" >> hosts
done
echo "The SSH servers became available"

echo "Execute the playbook"
export ANSIBLE_HOST_KEY_CHECKING=false
ansible-playbook -e 'ansible_python_interpreter=/usr/bin/python3' -T 300 -i hosts main.yml

echo "Cleanup the created linodes."
for ID in $(linode-cli linodes list --group="$LINODE_GROUP" --text --delimiter ";" --format 'id' --no-headers);
do
  linode-cli linodes delete "$ID"
done
