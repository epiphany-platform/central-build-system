## Goal
The code will let you automatically delete obsolete Tekton pipelinerun CRD kubernetes objects in the given namespace. It is important to do such house keeping systematically because each pipelinerun object is using particular amount of storage space within your cloud. The total amount of all such tekton PVCs can sum up to several hunreds of GB just after a few months of using the CBS.

## Installation and usage instructions
 to schedule a k8s cronjob that will automatically run and deleten the Tekton pipelinerun objects:
 - build the container based on the included Dockerfile:  
```docker build -t <your_local_tag> .```  
This container will include the *tkn_cleanup.sh* script which will remove your tekton objects correctly using tekton CLI tool. You can also manage this task using standard *kubectl* tool but the first on is more convenient when we want to preserve rotation period expressed in weeks.  
 - tag the container in a meaningful manner and upload it to the registory of your choice:  
 ```docker tag <your_local_tag> <your_docker_reg_tag>  && docker push <your_docker_reg_tag>```  
 - apply the kubernetes manifest file which will set up the automation; feel free to fine tune this config file before   
 ```kubectl -f apply tekton-cleanup.yaml```  
 This will keep deleting all objects older than *n* weeks, where *n* can be defined in the last line of the ```tekton-cleanup.yaml``` config file. Default value of *n* is 5. The deletion process will reoocur at the schedule defined also in the ```tekton-cleanup.yaml``` file.
 