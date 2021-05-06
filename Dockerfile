    FROM registry.access.redhat.com/ubi8/ubi-minimal
    WORKDIR /opt/operator
    ENV PATH="/opt/operator/bin:${PATH}"
    COPY artifact_dir artifact_dir
    COPY bin bin
    COPY crs crs
    COPY linux linux
    COPY operatorlist operatorlist
    COPY shared_dir shared_dir
    COPY vars.sh vars.sh
    #generate certified operator manifest
    RUN linux/offline-cataloger generate-manifests "certified-operators"
    RUN export manifest_directory=$(bin/find . -maxdepth 1 -name manifest*);chmod 777 $manifest_directory;echo -e "\nexport INSTALL_MANIFEST_DIRECTORY=$manifest_directory" >> vars.sh
    RUN chmod 777 vars.sh
    RUN chmod 777 bin/run.sh
    # Set arbitrary User ID
    USER 1001
    CMD ["/bin/bash"]