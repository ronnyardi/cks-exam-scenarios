#!/bin/bash

curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | sudo gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg && \
echo "deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main" | sudo tee -a /etc/apt/sources.list.d/falcosecurity.list && \
sudo apt-get update -y && \
sudo apt install -y dkms make linux-headers-$(uname -r) && \
sudo apt-get install -y falco

cat <<EOF >> /etc/falco/falco_rules.local.yaml
- macro: container_started
  condition: >
     (spawned_process and proc.vpid=1 and container)

- rule: Launch Privileged Container
  desc: > 
    Detect the initial process initiation within a privileged container, with exemptions for known and trusted images. 
    This rule primarily serves as an excellent auditing mechanism since highly privileged containers, when compromised, 
    can result in significant harm. For instance, if another rule triggers within such a privileged container, it could be 
    seen as more suspicious, prompting a closer inspection.
  condition: >
    container_started 
    and container.privileged=true
  output: Privileged container started | evt_type=%evt.type user=%user.name user_uid=%user.uid user_loginuid=%user.loginuid process=%proc.name proc_exepath=%proc.exepath parent=%proc.pname command=%proc.cmdline terminal=%proc.tty
  priority: INFO
  tags: [maturity_incubating, container, cis, mitre_execution, T1610, PCI_DSS_10.2.5]
EOF

sleep 5
touch /tmp/finished