# devbox-runtime

## Dockerfile Path 
As the YAML and Docker builds are based on the Dockerfile's path, it's necessary to establish a standardized convention for Dockerfile placement.

The top-level folders represent image categories, primarily divided into three types:
- OS
- Language
- Framework

The second-level directories denote specific image type, such as ubuntu, python, golang, etc., which will serve as the RuntimeClass name. 
The third-level directories correspond to specific versions, for example, go1.22.5, go1.23.0, etc. 
All Dockerfiles pushed to the repository should strictly adhere to these conventions. Therefore, an example of a compliant Dockerfile path would be:
`/Language/go/go1.22.5/Dockerfile`

## Get CRD
All CRD (Custom Resource Definition) files corresponding to the runtimes are located in the yaml folder. You can get yaml as follow:
```
git clone --filter=blob:none --sparse https://github.com/labring-actions/devbox-runtime.git
cd devbox-runtime
git sparse-checkout init --cone
git sparse-checkout set yaml
```

## Support Images

### System Images
- Ubuntu 24.04
- Ubuntu 22.04

### Language Images
- Go 1.23.0
- Go 1.22.5
- Python 3.12
- Python 3.11
- Python 3.10
- OpenJDK 17
- OpenJDK 11
- Rust 1.8.0
- Rust 1.79.0
- Node.js 22
- Node.js 21
- Node.js 20
- GCC

### Framework Images
- Gin
- Hertz
- Spring Boot
- Flask
- Next.js
- Vue