#!/bin/bash
cd microservices/terraform && terraform destroy -auto-approve && cd ../../infra/terraform && terraform destroy -auto-approve
