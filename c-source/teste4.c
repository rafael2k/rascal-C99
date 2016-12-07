extern int netdev_attach_ops(net_device *dev, net_device_ops *ops);

int main(){
	struct net_device *dev;
	struct net_device_ops ops;
	/* ... */
	dev->netdev_ops = &ops;
	/* ... */
	return 1;
}
