# version-checker demo

A demo using version checker and GKE cluster.

## Ensuring addons are up to date for a simplified Kubernetes upgrade

### Scenario

Upgrading Kubernetes can be a complex process, especially if add-ons (e.g., Cert-Manager, Istio, Flux, ingress-nginx, etc) are not compatible with the target Kubernetes version. Ensuring that add-ons are up-to-date simplifies the Kubernetes upgrade process and reduces the risk of incompatibilities. Similarly, keeping add-ons updated ensures that when it's time to upgrade Kubernetes, the process is smoother because the add-ons are already aligned with the latest versions.

This use case demonstrates how version-checker can help ensure add-ons are up-to-date, making Kubernetes upgrades simpler and more reliable.

**Challenges**
- A new GKE auto-upgrade happens overnight.
- A deployed workload uses an outdated container image that is now incompatible with the new Kubernetes version.
- Not being aware of these incompatibilities, causing broken deployments.
- Not getting alerts of images outdated

### Solution: Using Jetstack's Version Checker

Using version-checker can help with the following:

- Monitor Addon Versions
    - Use version-checker to monitor the versions of critical add-ons running in the cluster. 
    - version-checker tracks images from registries like GCR, Docker Hub, or quay.io.
    - Version Checker exposes metrics for these add-ons, showing whether they are using the latest available versions as well as latest kubernetes version
    - Alerts can be configured to notify you when an image is outdated. They can be set up via Slack, triggering a notification if an outdated add-on is detected before the next upgrade.
- Integration with Prometheus & Grafana for Visibility:.
    - Use Prometheus to collect these metrics and Grafana to visualize addons versions.
- Proactively Update Addons
    - Regularly check for updates to add-ons and ensure they are upgraded to the latest versions.
    - This ensures that add-ons are always compatible with the current Kubernetes version and prepared for future upgrades.
- Simplify Kubernetes Upgrades
    - When upgrading Kubernetes, verify that all add-ons are already using the latest versions compatible with the target Kubernetes version.
    - This reduces the risk of downtime or failures caused by outdated or incompatible add-ons.

### Implementation Steps

**Prerequisites**:
- A kubernetes cluster (GKE is used for demo)
```sh
make cluster
```

- Prometheus, Grafana and Alertmanager installed
```sh
make install-addons
```

- A CI/CD pipeline tool (GitHub Actions).
- Gatekeeper (Optional)

1. Deploy version checker via helm

```sh
make version-checker
```

2. Import version checker dashboard into Grafana
3. Visualize addons versions using Grafana dashboard
4. Add a step in the CI/CD pipeline to query version-checker metrics and validate add-on versions
5. Validate versions are up to date applying any (or both) of the following
    - Create a policy enforcement that only allows up to 2 minor or patch versions
    - Create script to validate during deployment pipeline
6. If any add-on is not using the latest version, apply any of the following:
    - The CI/CD pipeline fails with an error message
    - Audit logs warning addons are out of date (using gatekeeper)
