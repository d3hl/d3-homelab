# Machine configuration, bootstrap, and kubeconfig are managed by Omni.
# After VMs boot from the Omni ISO they register automatically via SideroLink.
# Use omnictl to create the cluster:
#
#   omnictl cluster template validate -f omni/templates/cluster.yaml
#   omnictl cluster template sync -f omni/templates/cluster.yaml --verbose
#   omnictl cluster template status -f omni/templates/cluster.yaml
#
# To get credentials once the cluster is healthy:
#   omnictl kubeconfig --cluster <name>   >> ~/.kube/config
#   omnictl talosconfig --cluster <name>  >> ~/.talos/config
