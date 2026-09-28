# NVIDIA VSS 3.1.0 LLM (vLLM)

NVIDIA VSS 3.1.0 LLM backend — standalone bounded vLLM serving the OpenAI API as llm-nim-svc:8000. In VSS 3.x this vLLM is the LLM for ALL platforms (there is no NIM-LLM), so this pack is present in every VSS 3.x profile (no include/omit contract). Default model is nvidia/NVIDIA-Nemotron-Nano-9B-v2-FP8 via nvcr.io/nvidia/vllm:25.12.post1-py3 (grounded in the 3.1.0 nemotron-nano-9b-v2-fp8 compose). The AGX-THOR/IGX-THOR preset swaps to the Jetson Thor image. Decode is NATIVE in 3.x (VIOS/rt-cv microservices) — this pack carries no decode flags.
