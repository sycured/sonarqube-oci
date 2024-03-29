FROM ghcr.io/graalvm/jdk:ol9-java17 as suexec
WORKDIR /opt
RUN microdnf update -y \
    && microdnf upgrade -y \
    && microdnf install -y gcc git make \
    && git clone -b master --single-branch https://github.com/ncopa/su-exec \
    && cd su-exec \
    && make

FROM ghcr.io/graalvm/jdk:ol9-java17
LABEL org.opencontainers.image.authors="sycured" org.opencontainers.image.source="https://github.com/sycured/sonarqube-oci"
ARG SONARQUBE_VERSION=9.9.3.79811 \
    SONAR_RUST_VERSION=0.2.2 \
    SONAR_CXX_PATCH_VERSION=488 \
    SONAR_CXX_VERSION=2.1.1 \
    BRANCH_PLUGIN_VERSION=1.14.0
ENV LANG='en_US.UTF-8' \
    SONAR_TELEMETRY_ENABLE=false \
    SONAR_VERSION=$SONARQUBE_VERSION \
    SONAR_CE_JAVAADDITIONALOPTS="-javaagent:./extensions/plugins/community-branch-plugin.jar=ce" \
    SONAR_WEB_JAVAADDITIONALOPTS="-javaagent:./extensions/plugins/community-branch-plugin.jar=web"
COPY run.sh sonar.sh /usr/local/bin/
COPY --from=suexec /opt/su-exec/su-exec /usr/local/bin/
RUN adduser -M sonarqube -s /bin/bash \
    && microdnf update -y \
    && microdnf upgrade -y \
    && microdnf install unzip -y \
    && rm -rf /var/cache/yum \
    && curl -sL -o /tmp/sonarqube.zip https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip \
    && unzip /tmp/sonarqube.zip -d /opt/ \
    && mv /opt/sonarqube-${SONARQUBE_VERSION} /opt/sonarqube \
    && curl -sL -o /opt/sonarqube/extensions/plugins/community-rust-plugin.jar https://github.com/elegoff/sonar-rust/releases/download/v${SONAR_RUST_VERSION}/community-rust-plugin-${SONAR_RUST_VERSION}.jar \
    && curl -sL -o /opt/sonarqube/extensions/plugins/sonar-cxx-plugin.jar https://github.com/SonarOpenCommunity/sonar-cxx/releases/download/cxx-${SONAR_CXX_VERSION}/sonar-cxx-plugin-${SONAR_CXX_VERSION}.${SONAR_CXX_PATCH_VERSION}.jar \
    && curl -sL -o /opt/sonarqube/extensions/plugins/community-branch-plugin.jar https://github.com/mc1arke/sonarqube-community-branch-plugin/releases/download/${BRANCH_PLUGIN_VERSION}/sonarqube-community-branch-plugin-${BRANCH_PLUGIN_VERSION}.jar \
    && chown -R sonarqube:sonarqube /opt/sonarqube \
    && chmod 777 /opt/sonarqube/data /opt/sonarqube/extensions /opt/sonarqube/logs /opt/sonarqube/temp \
    && echo "networkaddress.cache.ttl=5" >> "${JAVA_HOME}/conf/security/java.security" \
    && sed --in-place --expression="s?securerandom.source=file:/dev/random?securerandom.source=file:/dev/urandom?g" "${JAVA_HOME}/conf/security/java.security" \
    && rm /tmp/sonarqube.zip
USER sonarqube
WORKDIR /opt/sonarqube
EXPOSE 9000
STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/local/bin/run.sh"]
CMD ["/usr/local/bin/sonar.sh"]
