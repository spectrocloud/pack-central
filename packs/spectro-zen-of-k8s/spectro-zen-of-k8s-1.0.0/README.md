# zen-of-kubernetes
Can you beat the first level of Super Mario without increasing your heart rate? First, connect and establish your baseline heart rate. Then, once you're ready, you'll be given 60 seconds to beat the first level of Super Mario. Once you're finished, the delta between your maximum and baseline heart rates will be computed.

NOTE: this application is intended to be deployed on an edge device with Bluetooth enabled. Please refer to [The Zen of Kubernetes: building a secure edge demo for KubeCon Europe](https://www.spectrocloud.com/blog/the-zen-of-kubernetes-building-a-secure-edge-demo-for-kubecon-europe/) blog post for additional details.

![zen-done-small](https://user-images.githubusercontent.com/1795270/232923327-4577aa71-de24-4939-8a5c-51b8f94cb8f9.png)

### heartrate-monitor
Uses [tinygo.org/x/bluetooth](https://github.com/tinygo-org/bluetooth) to connect with a heart rate monitoring device. Provides a basic webserver to expose connect, baseline, challenge, and disconnect functionality.

### heartrate-ui
Front end for the heart rate monitor server.
