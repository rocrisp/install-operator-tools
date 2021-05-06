FROM registry.access.redhat.com/ubi8/ubi-minimal
    WORKDIR /opt/operator
    COPY artifact_dir artifact_dir
    COPY bin bin
    COPY linux linux
    COPY operatorlist operatorlist
    COPY shared_dir shared_dir
    COPY vars.sh vars.sh
    #generate certified operator manifest
    RUN linux/offline-cataloger generate-manifests "certified-operators"
    RUN chmod +x bin/run.sh
    RUN export manifest_directory=$(bin/find . -maxdepth 1 -name manifest*);echo -e "\nexport INSTALL_MANIFEST_DIRECTORY=$manifest_directory" >> vars.sh
    CMD ["bin/run.sh"] 