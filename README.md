# sonarqube-oci
Custom sonarqube OCI image

```bash
podman pull quay.io/sycured/sonarqube-oci
```

## Customizations

- Base image: [GraalVM CE](https://www.graalvm.org/java/)
- [Community Branch Plugin](https://github.com/mc1arke/sonarqube-community-branch-plugin) added
- [Sonar Rust](https://github.com/elegoff/sonar-rust) added
- Telemetry disabled by default