#!/bin/bash
# Verify kube-apiserver audit logging configuration and runtime status
# Exits 0 if all checks pass, non-zero otherwise.

MANIFEST_DIR="/etc/kubernetes/manifests"
AUDIT_DIR="/var/log/kubernetes/audit"

set +e

fail=0

echo "Locating kube-apiserver manifest under ${MANIFEST_DIR}..."
APISERVER_MANIFEST=""
if [ -d "$MANIFEST_DIR" ]; then
  APISERVER_MANIFEST=$(grep -lR --include='*.yaml' --include='*.yml' "kube-apiserver" "$MANIFEST_DIR" 2>/dev/null | head -n1)
fi
if [ -z "$APISERVER_MANIFEST" ]; then
  echo "FAIL: kube-apiserver manifest not found in ${MANIFEST_DIR}"
  fail=1
else
  echo "Found manifest: $APISERVER_MANIFEST"
fi

# Helper to extract flag values from manifest (searches anywhere in file)
get_manifest_flag() {
  local flag="$1"
  # match --flag=value or -flag=value
  grep -oE "(--|-)${flag}=[^[:space:],']+" "$APISERVER_MANIFEST" 2>/dev/null | head -n1 | sed -E "s/^(--|-)${flag}=//"
}

# Only proceed if manifest found
if [ -n "$APISERVER_MANIFEST" ]; then
  echo
  echo "Checking audit-related flags in manifest..."

  policy_file=$(get_manifest_flag "audit-policy-file")
  if [ -n "$policy_file" ]; then
    echo "OK: audit-policy-file set to: $policy_file"
  else
    echo "FAIL: audit-policy-file flag not found in manifest"
    fail=1
  fi

  audit_path=$(get_manifest_flag "audit-log-path")
  if [ -n "$audit_path" ]; then
    if [[ "$audit_path" == ${AUDIT_DIR}* ]]; then
      echo "OK: audit-log-path set to: $audit_path"
    else
      echo "FAIL: audit-log-path is set to '$audit_path' but should be under ${AUDIT_DIR}"
      fail=1
    fi
  else
    echo "FAIL: audit-log-path flag not found in manifest"
    fail=1
  fi

  maxage=$(get_manifest_flag "audit-log-maxage")
  if [ "$maxage" = "30" ]; then
    echo "OK: audit-log-maxage=30"
  else
    echo "FAIL: audit-log-maxage is '${maxage:-<missing>}' (expected 30)"
    fail=1
  fi

  maxbackup=$(get_manifest_flag "audit-log-maxbackup")
  if [ "$maxbackup" = "10" ]; then
    echo "OK: audit-log-maxbackup=10"
  else
    echo "FAIL: audit-log-maxbackup is '${maxbackup:-<missing>}' (expected 10)"
    fail=1
  fi

  maxsize=$(get_manifest_flag "audit-log-maxsize")
  if [ "$maxsize" = "150" ]; then
    echo "OK: audit-log-maxsize=150"
  else
    echo "FAIL: audit-log-maxsize is '${maxsize:-<missing>}' (expected 150)"
    fail=1
  fi

  echo
  echo "Checking manifest contains hostPath/volumeMount for ${AUDIT_DIR}..."
  grep -qF "mountPath: ${AUDIT_DIR}" "$APISERVER_MANIFEST" 2>/dev/null
  mount_found=$?
  grep -qF "path: ${AUDIT_DIR}" "$APISERVER_MANIFEST" 2>/dev/null
  hostpath_found=$?
  if [ $mount_found -eq 0 ] && [ $hostpath_found -eq 0 ]; then
    echo "OK: manifest contains both mountPath and hostPath entries for ${AUDIT_DIR}"
  else
    echo "FAIL: manifest is missing mountPath or hostPath for ${AUDIT_DIR}"
    echo "  - mountPath present: $([ $mount_found -eq 0 ] && echo yes || echo no)"
    echo "  - hostPath present:  $([ $hostpath_found -eq 0 ] && echo yes || echo no)"
    fail=1
  fi

  echo
  echo "Checking host directory ${AUDIT_DIR} exists and writable..."
  if [ -d "${AUDIT_DIR}" ]; then
    if [ -w "${AUDIT_DIR}" ]; then
      echo "OK: ${AUDIT_DIR} exists and is writable"
    else
      echo "WARN: ${AUDIT_DIR} exists but is not writable by current user"
    fi
  else
    echo "WARN: ${AUDIT_DIR} does not exist on host"
  fi

  echo
  echo "Checking kube-apiserver runtime (process) reflects the configuration..."
  # Find running process
  apiserver_proc=$(pgrep -a -f "kube-apiserver" 2>/dev/null | head -n1)
  if [ -z "$apiserver_proc" ]; then
    echo "FAIL: kube-apiserver process not found on this node"
    fail=1
  else
    echo "Found process: $apiserver_proc"
    # verify runtime flags contain expected values (simple substring checks)
    check_proc_flag() {
      local flag="$1"
      local expect="$2"
      if echo "$apiserver_proc" | grep -q -- "$flag"; then
        if [ -n "$expect" ]; then
          if echo "$apiserver_proc" | grep -q -- "$expect"; then
            echo "OK: process contains $flag with expected value"
            return 0
          else
            echo "FAIL: process contains $flag but value does not match expected ($expect)"
            return 1
          fi
        else
          echo "OK: process contains $flag"
          return 0
        fi
      else
        echo "FAIL: process missing $flag"
        return 1
      fi
    }

    check_proc_flag "--audit-policy-file" "$policy_file" || fail=1
    check_proc_flag "--audit-log-path" "$audit_path" || fail=1
    check_proc_flag "--audit-log-maxage=30" "" || fail=1
    check_proc_flag "--audit-log-maxbackup=10" "" || fail=1
    check_proc_flag "--audit-log-maxsize=150" "" || fail=1
  fi
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "All checks passed: kube-apiserver audit logging appears correctly configured and running."
  exit 0
else
  echo "One or more checks failed. Please review the messages above and correct the manifest/configuration."
  exit 1
fi