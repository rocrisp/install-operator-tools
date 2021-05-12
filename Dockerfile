    FROM registry.access.redhat.com/ubi7/ubi
    LABEL name="InstallOperator" \
      vendor="Redhat" \
      maintainer="Rose Crisp" \
      version="1.0" \
      summary="Installs operator on a cluster" \
      description="Automate installing of operators on a cluster"
    WORKDIR /opt/operator
    RUN chgrp -R 0 /opt/operator && \
        chmod -R g=u /opt/operator
    COPY bin bin
    RUN yum install -y wget
    RUN wget https://github.com/mikefarah/yq/releases/download/v4.2.0/yq_linux_amd64 -O bin/yq && \
        chmod +x bin/yq
    RUN wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O bin/jq && \
        chmod +x bin/jq

    ENV PATH="/opt/operator/bin:/usr/bin:${PATH}"
    COPY artifact_dir artifact_dir 
    COPY crs crs
    COPY linux linux
    COPY operatorlist operatorlist
    COPY shared_dir shared_dir
    COPY vars.sh vars.sh
    RUN chgrp -R 0 /opt/operator/crs && \
        chmod -R g=u /opt/operator/crs && \
        chgrp -R 0 /opt/operator/shared_dir && \
        chmod -R g=u /opt/operator/shared_dir && \
        chgrp -R 0 /opt/operator/artifact_dir && \
        chmod -R g=u /opt/operator/artifact_dir && \
        chgrp -R 0 /opt/operator/operatorlist && \
        chmod -R g=u /opt/operator/operatorlist

    #generate certified operator manifest
    RUN linux/offline-cataloger generate-manifests "certified-operators"
    RUN export manifest_directory=$(bin/find . -maxdepth 1 -name manifest*);chmod 777 $manifest_directory;echo -e "\nexport INSTALL_MANIFEST_DIRECTORY=$manifest_directory" >> vars.sh
    RUN chmod 777 vars.sh
    RUN chmod 777 bin/run.sh
    ENTRYPOINT ["/bin/bash"]