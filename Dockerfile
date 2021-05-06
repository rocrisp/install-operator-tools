    FROM registry.access.redhat.com/ubi8/ubi-minimal
    WORKDIR /opt/operator
    ENV PATH="/opt/operator//bin:${PATH}"
    COPY artifact_dir artifact_dir 
    COPY bin bin 
    COPY linux linux 
    COPY operatorlist operatorlist 
    COPY shared_dir shared_dir 
    COPY vars.sh vars.sh 
    #generate certified operator manifest
    RUN linux/offline-cataloger generate-manifests "certified-operators"
    RUN export manifest_directory=$(find . -maxdepth 1 -name manifest*);echo -e "\nexport INSTALL_MANIFEST_DIRECTORY=$manifest_directory" >> vars.sh  
    CMD ["run.sh"] 
