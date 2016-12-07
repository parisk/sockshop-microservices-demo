#!/usr/bin/env bash

echo "Terminating load balancers..."
aws elb delete-load-balancer --load-balancer-name MD-k8s-elb-sock-shop &>/dev/null
aws elb delete-load-balancer --load-balancer-name MD-k8s-elb-scope &>/dev/null

instances=$(aws ec2 describe-instances --filter "Name=tag:Name,Values=MD-k8s-master,MD-k8s-node" | jq -r '.Reservations[].Instances[].InstanceId')
echo 'Terminating instances...'
aws ec2 terminate-instances --instance-ids $instances &>/dev/null

echo 'Waiting for instances to terminate...'
aws ec2 wait instance-terminated --instance-ids $instances &>/dev/null


echo 'Terminating security group...'
aws ec2 delete-security-group --group-name MD-k8s-security-group 


echo 'Terminating key...'
aws ec2 delete-key-pair --key-name microservices-demo-flux &>/dev/null
