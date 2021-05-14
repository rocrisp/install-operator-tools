FROM registry.access.redhat.com/ubi8/ubi-minimal@sha256:2f6b88c037c0503da7704bccd3fc73cb76324101af39ad28f16460e7bce98324
LABEL name="InstallOperator" \
      vendor="Redhat" \
      maintainer="Rose Crisp, John McKenzie, Melvin Hillsman" \
      version="1.0" \
      summary="Installs operator on a cluster" \
      description="Automate installing of operators on a cluster"}
WORKDIR /var/operator
    
COPY bin /opt/operator/bin/ 
COPY vars.sh /opt/operator/

RUN microdnf install findutils gzip tar && microdnf clean all
RUN curl -Lo /usr/local/bin/offline-cataloger https://github.com/kevinrizza/offline-cataloger/releases/download/0.0.1/offline-cataloger
RUN curl -Lo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
RUN curl -Lo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.7.1/yq_linux_amd64
RUN curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux-4.7.9.tar.gz | tar -xzv -C /usr/local/bin --exclude README.md

RUN chmod 755 /usr/local/bin/*
RUN chmod 775 /var/operator
CMD ["/opt/operator/bin/run.sh"]