cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: alb-controller
rules:
- apiGroups: [""]
  resources: ["configmaps", "endpoints", "events", "pods", "services", "secrets", "nodes"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["gateway.networking.k8s.io"]
  resources: ["gatewayclasses", "gateways", "httproutes", "referencegrants"]
  verbs: ["get", "list", "watch", "update", "patch"]
- apiGroups: ["gateway.networking.k8s.io"]
  resources: ["gatewayclasses/status", "gateways/status", "httproutes/status"]
  verbs: ["update", "patch"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch"]
EOF


cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: alb-controller-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: alb-controller
subjects:
- kind: ServiceAccount
  name: alb-controller-sa
  namespace: azure-alb-system
EOF


and add role contributor to alb-managed-identity with scope   the  app gateway for container 