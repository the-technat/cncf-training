# Lima

Local K8s setup using Lima, native on Apple Silicon.

https://gist.github.com/PhilipSchmid/e34a725d5836d21432fd10b0709a5c4a

## Prerequisites

- lima (`brew install lima`)
- ssh key to use

## Provision VMs

To get the VMs up & running do the following:

```console
limactl create --name=master-01 ./vm-template.yaml --tty=false
limactl create --name=worker-01 ./vm-template.yaml --tty=false
limactl create --name=worker-02 ./vm-template.yaml --tty=false
limactl start master-01 
limactl start worker-01 
limactl start worker-02
```

If you want the environment to boot on start-up you can additionally do the following:

```console
limactl start-at-login master-01
limactl start-at-login worker-01
limactl start-at-login worker-02
```

As a final step you should add the following lines to your ssh config to make sure lima VM's are reachable over ssh:

```console
echo "Include /Users/technat/.lima/*/ssh.config" >> ~/.ssh/config
ssh lima-master-01 
```

The second command should give you a shell insied the first master-node instantly without promping for a password.


## Provision K8s

For the CNCF trainings you need a cluster setup with plain Kubeadm as you usually are going to mess with it later on.

For this we use [kubespray](https://github.com/kubernetes-sigs/kubespray).
