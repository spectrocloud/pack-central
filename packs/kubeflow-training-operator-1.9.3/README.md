# Kubeflow Training Operator

Kubeflow Training Operator is a Kubernetes-native project for fine-tuning and scalable distributed training of machine learning (ML) models created with various ML frameworks such as PyTorch, TensorFlow, HuggingFace, JAX, DeepSpeed, XGBoost, PaddlePaddle and others.

You can run high-performance computing (HPC) tasks with the Training Operator and MPIJob since it supports running Message Passing Interface (MPI) on Kubernetes which is heavily used for HPC. This pack defaults to installinh the V1 API version of MPI Operator. For the MPI Operator V2 version, please adjust the preset in the pack to MPI Operator v2.

The Training Operator allows you to use Kubernetes workloads to effectively train your large models via Kubernetes Custom Resources APIs or using the Training Operator Python SDK.