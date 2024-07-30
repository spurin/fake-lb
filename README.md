# fake-lb

`fake-lb` is a lightweight, dummy load balancer designed for local testing in Kubernetes environments. It assigns external IPs from the nodes' internal IPs to services of type `LoadBalancer` without needing a real load balancing solution. This tool is ideal for development and testing purposes, where full load balancing functionality isn't required.

## Installation

To install `fake-lb` in your Kubernetes cluster, run the following command:

```bash
kubectl apply -f https://github.com/spurin/fake-lb/fake-lb.yaml
```

## Uninstallation

To remove fake-lb from your Kubernetes cluster, use the same YAML file used for installation:

```
kubectl delete -f https://github.com/spurin/fake-lb/fake-lb.yaml
```

This command will clean up all resources associated with fake-lb, ensuring that no components are left behind.

## Configuration

The default configuration applies the external IPs from node internal IPs to all services of type LoadBalancer that don't already have an external IP set. It operates in the kube-system namespace to align with typical Kubernetes practices for infrastructure-related services.

If you need to customise the behavior of fake-lb, you can clone the repository, modify the fake-lb.yaml file and apply it using:

```
kubectl apply -f path/to/your/local/fake-lb.yaml
```

## Example Usage

With fake-lb running, LoadBalancer services will be assigned the External-IP's of the node.

We can then use the NodePort assignment (31746 in this example), to access the service via the Node IP -

```
root@control-plane:~# kubectl get service
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP                        PORT(S)          AGE
kubernetes   ClusterIP      10.43.0.1       <none>                             443/TCP          173m
nginx        LoadBalancer   10.43.237.179   172.18.0.2,172.18.0.3,172.18.0.4   8080:31746/TCP   6m59s

root@control-plane:~#
root@control-plane:~# curl 172.18.0.2:31746
<!DOCTYPE html>
<body>
<p><em>Hostname: nginx-77b46474f5-752zn</em></p>
<p><em>IP Address: 10.42.226.66:80</em></p>
<p><em>URL: /</em></p>
<p><em>Request Method: GET</em></p>
<p><em>Request ID: 4f285b1d196495fa64b11665782f5362</em></p>
</body>
</html>
```