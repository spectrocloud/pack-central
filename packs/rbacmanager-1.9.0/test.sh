ADMIN_USER=rishi+rw@spectrocloud.com
VIEW_USER=rishi+r@spectrocloud.com
CLUSTER_ADMIN_USER=arvind@spectrocloud.com

ONLY_ADMIN_USER_ACCESS_NS=only-admin-test
ONLY_VIEW_USER_ACCESS_NS=only-view-test
ADMIN_VIEW_USER_ACCESS_NS=admin-view-test
CLUSTER_ADMIN_USER_ACCESS_NS=cluster-admin-test

ADMIN_LABEL="admin=access"
VIEW_LABEL="view=access"
ADMIN_VIEW_LABEL="admin=access, view=access"

#admin
echo "************** ADMIN USER **************"
echo $ADMIN_USER
echo "------------- create -------------"
echo "Admin is allowed to create pod in $ONLY_ADMIN_USER_ACCESS_NS namespace ($ADMIN_LABEL): "
kubectl auth can-i create pods --as=$ADMIN_USER -n $ONLY_ADMIN_USER_ACCESS_NS
#echo "Admin is allowed to create pod in $ONLY_VIEW_USER_ACCESS_NS namespace ($VIEW_LABEL): "
#kubectl auth can-i create pods --as=$ADMIN_USER -n $ONLY_VIEW_USER_ACCESS_NS
echo "Admin is allowed to create pod in $ADMIN_VIEW_USER_ACCESS_NS namespace ($ADMIN_VIEW_LABEL): "
kubectl auth can-i create pods --as=$ADMIN_USER -n $ADMIN_VIEW_USER_ACCESS_NS
echo "Admin is allowed to create pod in $CLUSTER_ADMIN_USER_ACCESS_NS namespace: "
kubectl auth can-i create pods --as=$ADMIN_USER -n $CLUSTER_ADMIN_USER_ACCESS_NS

echo "------------- list -------------"
echo "Admin is allowed to list pod in $ONLY_ADMIN_USER_ACCESS_NS namespace ($ADMIN_LABEL): "
kubectl auth can-i list pods --as=$ADMIN_USER -n only-admin-test
echo "Admin is allowed to list pod in $ONLY_VIEW_USER_ACCESS_NS namespace ($VIEW_LABEL): "
kubectl auth can-i list pods --as=$ADMIN_USER -n $ONLY_VIEW_USER_ACCESS_NS
echo "Admin is allowed to list pod in $ADMIN_VIEW_USER_ACCESS_NS namespace ($ADMIN_VIEW_LABEL): "
kubectl auth can-i list pods --as=$ADMIN_USER -n $ADMIN_VIEW_USER_ACCESS_NS
echo "Admin is allowed to list pod in $CLUSTER_ADMIN_USER_ACCESS_NS namespace: "
kubectl auth can-i list pods --as=$ADMIN_USER -n $CLUSTER_ADMIN_USER_ACCESS_NS

##view
echo "************** VIEW USER **************"
echo $VIEW_USER
echo "------------- create -------------"
echo "View is allowed to create pod in $ONLY_ADMIN_USER_ACCESS_NS namespace ($ADMIN_LABEL): "
kubectl auth can-i create pods --as=$VIEW_USER -n only-admin-test
echo "View is allowed to create pod in $ONLY_VIEW_USER_ACCESS_NS namespace ($VIEW_LABEL): "
kubectl auth can-i create pods --as=$VIEW_USER -n $ONLY_VIEW_USER_ACCESS_NS
echo "View is allowed to create pod in $ADMIN_VIEW_USER_ACCESS_NS namespace ($ADMIN_VIEW_LABEL): "
kubectl auth can-i create pods --as=$VIEW_USER -n $ADMIN_VIEW_USER_ACCESS_NS
echo "View is allowed to create pod in $CLUSTER_ADMIN_USER_ACCESS_NS namespace: "
kubectl auth can-i create pods --as=$VIEW_USER -n $CLUSTER_ADMIN_USER_ACCESS_NS

echo "------------- list -------------"
echo "View is allowed to list pod in $ONLY_ADMIN_USER_ACCESS_NS namespace ($ADMIN_LABEL): "
kubectl auth can-i list pods --as=$VIEW_USER -n only-admin-test
echo "View is allowed to list pod in $ONLY_VIEW_USER_ACCESS_NS namespace ($VIEW_LABEL): "
kubectl auth can-i list pods --as=$VIEW_USER -n $ONLY_VIEW_USER_ACCESS_NS
echo "View is allowed to list pod in $ADMIN_VIEW_USER_ACCESS_NS namespace ($ADMIN_VIEW_LABEL): "
kubectl auth can-i list pods --as=$VIEW_USER -n $ADMIN_VIEW_USER_ACCESS_NS
echo "View is allowed to list pod in $CLUSTER_ADMIN_USER_ACCESS_NS namespace: "
kubectl auth can-i list pods --as=$VIEW_USER -n $CLUSTER_ADMIN_USER_ACCESS_NS

#cluster-admin
echo "************** CLUSTER ADMIN USER **************"
echo $CLUSTER_ADMIN_USER
echo "------------- create -------------"
echo "ClusterAdmin is allowed to create pod in $ONLY_ADMIN_USER_ACCESS_NS namespace ($ADMIN_LABEL): "
kubectl auth can-i create pods --as=$CLUSTER_ADMIN_USER -n only-admin-test
echo "ClusterAdmin is allowed to create pod in $ONLY_VIEW_USER_ACCESS_NS namespace ($VIEW_LABEL): "
kubectl auth can-i create pods --as=$CLUSTER_ADMIN_USER -n $ONLY_VIEW_USER_ACCESS_NS
echo "ClusterAdmin is allowed to create pod in $ADMIN_VIEW_USER_ACCESS_NS namespace ($ADMIN_VIEW_LABEL): "
kubectl auth can-i create pods --as=$CLUSTER_ADMIN_USER -n $ADMIN_VIEW_USER_ACCESS_NS
echo "ClusterAdmin is allowed to create pod in $CLUSTER_ADMIN_USER_ACCESS_NS namespace: "
kubectl auth can-i create pods --as=$CLUSTER_ADMIN_USER -n $CLUSTER_ADMIN_USER_ACCESS_NS

echo "------------- list -------------"
echo "ClusterAdmin is allowed to list pod in $ONLY_ADMIN_USER_ACCESS_NS namespace ($ADMIN_LABEL): "
kubectl auth can-i list pods --as=$CLUSTER_ADMIN_USER -n only-admin-test
echo "ClusterAdmin is allowed to list pod in $ONLY_VIEW_USER_ACCESS_NS namespace ($VIEW_LABEL): "
kubectl auth can-i list pods --as=$CLUSTER_ADMIN_USER -n $ONLY_VIEW_USER_ACCESS_NS
echo "ClusterAdmin is allowed to list pod in $ADMIN_VIEW_USER_ACCESS_NS namespace ($ADMIN_VIEW_LABEL): "
kubectl auth can-i list pods --as=$CLUSTER_ADMIN_USER -n $ADMIN_VIEW_USER_ACCESS_NS
echo "ClusterAdmin is allowed to list pod in $CLUSTER_ADMIN_USER_ACCESS_NS namespace: "
kubectl auth can-i list pods --as=$CLUSTER_ADMIN_USER -n $CLUSTER_ADMIN_USER_ACCESS_NS
