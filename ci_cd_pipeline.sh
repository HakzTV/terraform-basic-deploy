#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

TF_CMD="${TF_CMD:-terraform}"
PLAN_FILE="${PLAN_FILE:-tfplan}"

usage() {
  cat <<EOF
Usage: $0 <command>

Commands:
  init       Initialize Terraform working directory
  fmt        Format Terraform files and check formatting
  validate   Validate Terraform configuration
  plan       Create an execution plan and save it to ${PLAN_FILE}
  apply      Apply the saved Terraform plan
  deploy     Run init, fmt, validate, plan, and apply
  destroy    Destroy all managed infrastructure
  help       Show this help message

Environment variables:
  AZ_CLIENT_ID         Azure Service Principal client ID
  AZ_CLIENT_SECRET     Azure Service Principal client secret
  AZ_TENANT_ID         Azure tenant ID
  AZ_SUBSCRIPTION_ID   Azure subscription ID
  TF_VAR_project_name   Terraform project_name variable override
  TF_VAR_location       Terraform location variable override
  TF_VAR_environment    Terraform environment variable override
EOF
}

check_azure_env() {
  local missing=()
  for var in AZ_CLIENT_ID AZ_CLIENT_SECRET AZ_TENANT_ID AZ_SUBSCRIPTION_ID; do
    if [[ -z "${!var:-}" ]]; then
      missing+=("$var")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "Error: missing required Azure auth environment variables: ${missing[*]}"
    echo "Set the Azure service principal values before running this script."
    exit 1
  fi
}

init() {
  echo "==> Initializing Terraform"
  check_azure_env
  "$TF_CMD" init -input=false
}

fmt() {
  echo "==> Formatting Terraform files"
  "$TF_CMD" fmt -check -recursive
}

validate() {
  echo "==> Validating Terraform configuration"
  check_azure_env
  "$TF_CMD" validate
}

plan() {
  echo "==> Creating Terraform plan"
  check_azure_env
  "$TF_CMD" plan -input=false -out="$PLAN_FILE"
}

apply() {
  echo "==> Applying Terraform plan"
  if [[ ! -f "$PLAN_FILE" ]]; then
    echo "Error: plan file '$PLAN_FILE' not found. Run '$0 plan' first."
    exit 1
  fi
  "$TF_CMD" apply -input=false -auto-approve "$PLAN_FILE"
}

deploy() {
  fmt
  init
  validate
  plan
  apply
}

destroy() {
  echo "==> Destroying Terraform-managed infrastructure"
  check_azure_env
  "$TF_CMD" destroy -auto-approve -input=false
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

case "$1" in
  init) init ;;
  fmt) fmt ;;
  validate) validate ;;
  plan) plan ;;
  apply) apply ;;
  deploy) deploy ;;
  destroy) destroy ;;
  help|--help|-h) usage ;;
  *)
    echo "Unknown command: $1"
    usage
    exit 1
    ;;
esac
