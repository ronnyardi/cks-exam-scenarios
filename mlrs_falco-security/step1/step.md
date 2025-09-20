# Step 1: Monitor Falco Alerts and Mitigate the Threats

There are deployments already running in the cluster. Monitor the Falco logs in the worker node to detect which containers have triggered the security rules. Once identified, scale down the corresponding deployments to 0 replicas to mitigate the threats.

<details>
  <summary>Solution</summary>

1. View the Falco logs to identify which containers have triggered the security rules:

    ```sh
    sudo cat /var/log/syslog | grep "Falco"
    ```

2. Scale down the compromised deployments to 0 replicas to mitigate the threats:

    ```bash
    kubectl scale deployment monstrous-kraken --replicas=0 -n falco-test
    kubectl scale deployment zany-smile --replicas=0 -n falco-test
    ```

</details>
