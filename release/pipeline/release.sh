
#Create Task
oc apply -f release-task.yaml


#Create Service Account
cat <<EOF | oc apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: release-plan-openshift-pipelines-role
rules:
- apiGroups:
  - appstudio.redhat.com
  resources:
  - snapshots
  - releaseplans
  verbs:
  - get
  - list

EOF

tkn task start konflux-release-task \
  --serviceaccount=release-registry-openshift-pipelines \
  --param APPLICATION=openshift-pipelines-core-1-22 \
  --param ENVIRONMENT=stage \
  --showlog