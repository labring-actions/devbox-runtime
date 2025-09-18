```mermaid
graph TD
    runtimes_frameworks_docusaurus_3.5.2_Dockerfile["docusaurus-3.5.2"]
    node.js_20 --> runtimes_frameworks_docusaurus_3.5.2_Dockerfile
    runtimes_frameworks_hugo_v0.135.0_Dockerfile["hugo-v0.135.0"]
    go_1.22.5 --> runtimes_frameworks_hugo_v0.135.0_Dockerfile
    runtimes_frameworks_iris_v12.2.11_Dockerfile["iris-v12.2.11"]
    go_1.22.5 --> runtimes_frameworks_iris_v12.2.11_Dockerfile
    runtimes_frameworks_spring-boot_3.3.2_Dockerfile["spring-boot-3.3.2"]
    java_openjdk17 --> runtimes_frameworks_spring-boot_3.3.2_Dockerfile
    runtimes_frameworks_svelte_6.4.0_Dockerfile["svelte-6.4.0"]
    node.js_20 --> runtimes_frameworks_svelte_6.4.0_Dockerfile
    runtimes_languages_go_1.22.5_Dockerfile["go-1.22.5"]
    debian_ssh_12.6 --> runtimes_languages_go_1.22.5_Dockerfile
    runtimes_languages_go_1.23.0_Dockerfile["go-1.23.0"]
    debian_ssh_12.6 --> runtimes_languages_go_1.23.0_Dockerfile
    runtimes_languages_net_8.0_Dockerfile["net-8.0"]
    debian_ssh_12.6 --> runtimes_languages_net_8.0_Dockerfile
    runtimes_frameworks_express.js_4.21.0_Dockerfile["express.js-4.21.0"]
    node.js_20 --> runtimes_frameworks_express.js_4.21.0_Dockerfile
    runtimes_frameworks_gin_v1.10.0_Dockerfile["gin-v1.10.0"]
    go_1.22.5 --> runtimes_frameworks_gin_v1.10.0_Dockerfile
    runtimes_frameworks_vert.x_4.5.10_Dockerfile["vert.x-4.5.10"]
    java_openjdk17 --> runtimes_frameworks_vert.x_4.5.10_Dockerfile
    runtimes_languages_java_openjdk17_Dockerfile["java-openjdk17"]
    debian_ssh_12.6 --> runtimes_languages_java_openjdk17_Dockerfile
    runtimes_languages_python_3.10_Dockerfile["python-3.10"]
    debian_ssh_12.6 --> runtimes_languages_python_3.10_Dockerfile
    runtimes_languages_rust_1.81.0_Dockerfile["rust-1.81.0"]
    debian_ssh_12.6 --> runtimes_languages_rust_1.81.0_Dockerfile
    runtimes_operating-systems_debian-ssh_12.6_Dockerfile["debian-ssh-12.6"]
    runtimes_operating-systems_ubuntu-cuda_24.04_Dockerfile["ubuntu-cuda-24.04"]
    runtimes_frameworks_nuxt3_v3.13_Dockerfile["nuxt3-v3.13"]
    node.js_20 --> runtimes_frameworks_nuxt3_v3.13_Dockerfile
    runtimes_frameworks_quarkus_3.16.1_Dockerfile["quarkus-3.16.1"]
    java_openjdk17 --> runtimes_frameworks_quarkus_3.16.1_Dockerfile
    runtimes_frameworks_vue_v3.4.29_Dockerfile["vue-v3.4.29"]
    node.js_20 --> runtimes_frameworks_vue_v3.4.29_Dockerfile
    runtimes_languages_c_gcc-12.2.0_Dockerfile["c-gcc-12.2.0"]
    debian_ssh_12.6 --> runtimes_languages_c_gcc-12.2.0_Dockerfile
    runtimes_frameworks_echo_v4.12.0_Dockerfile["echo-v4.12.0"]
    go_1.22.5 --> runtimes_frameworks_echo_v4.12.0_Dockerfile
    runtimes_frameworks_flask_3.0.3_Dockerfile["flask-3.0.3"]
    python_3.12 --> runtimes_frameworks_flask_3.0.3_Dockerfile
    runtimes_frameworks_react_18.2.0_Dockerfile["react-18.2.0"]
    node.js_22 --> runtimes_frameworks_react_18.2.0_Dockerfile
    runtimes_languages_node.js_18_Dockerfile["node.js-18"]
    debian_ssh_12.6 --> runtimes_languages_node.js_18_Dockerfile
    runtimes_languages_php_8.2.20_Dockerfile["php-8.2.20"]
    debian_ssh_12.6 --> runtimes_languages_php_8.2.20_Dockerfile
    runtimes_languages_python_3.11_Dockerfile["python-3.11"]
    debian_ssh_12.6 --> runtimes_languages_python_3.11_Dockerfile
    runtimes_services_mcp_csharp-1-0_Dockerfile["mcp-csharp-1-0"]
    debian_ssh_12.6 --> runtimes_services_mcp_csharp-1-0_Dockerfile
    runtimes_services_mcp_mcp-proxy_Dockerfile["mcp-mcp-proxy"]
    debian_ssh_12.6 --> runtimes_services_mcp_mcp-proxy_Dockerfile
    runtimes_frameworks_next.js_14.2.5_Dockerfile["next.js-14.2.5"]
    node.js_20 --> runtimes_frameworks_next.js_14.2.5_Dockerfile
    runtimes_frameworks_nginx_1.22.1_Dockerfile["nginx-1.22.1"]
    node.js_20 --> runtimes_frameworks_nginx_1.22.1_Dockerfile
    runtimes_languages_cpp_gcc-12.2.0_Dockerfile["cpp-gcc-12.2.0"]
    debian_ssh_12.6 --> runtimes_languages_cpp_gcc-12.2.0_Dockerfile
    runtimes_languages_python_3.12_Dockerfile["python-3.12"]
    debian_ssh_12.6 --> runtimes_languages_python_3.12_Dockerfile
    runtimes_operating-systems_ubuntu_24.04_Dockerfile["ubuntu-24.04"]
    runtimes_services_mcp_spring-boot-3-3-2_Dockerfile["mcp-spring-boot-3-3-2"]
    debian_ssh_12.6 --> runtimes_services_mcp_spring-boot-3-3-2_Dockerfile
    runtimes_services_mcp_typescript-1-8_Dockerfile["mcp-typescript-1-8"]
    debian_ssh_12.6 --> runtimes_services_mcp_typescript-1-8_Dockerfile
    runtimes_frameworks_astro_4.10.0_Dockerfile["astro-4.10.0"]
    node.js_20 --> runtimes_frameworks_astro_4.10.0_Dockerfile
    runtimes_frameworks_hexo_7.3.0_Dockerfile["hexo-7.3.0"]
    node.js_20 --> runtimes_frameworks_hexo_7.3.0_Dockerfile
    runtimes_frameworks_rocket_0.5.1_Dockerfile["rocket-0.5.1"]
    rust_1.81.0 --> runtimes_frameworks_rocket_0.5.1_Dockerfile
    runtimes_frameworks_umi_4.3.27_Dockerfile["umi-4.3.27"]
    node.js_20 --> runtimes_frameworks_umi_4.3.27_Dockerfile
    runtimes_frameworks_angular_v18_Dockerfile["angular-v18"]
    node.js_20 --> runtimes_frameworks_angular_v18_Dockerfile
    runtimes_frameworks_chi_v5.1.0_Dockerfile["chi-v5.1.0"]
    go_1.22.5 --> runtimes_frameworks_chi_v5.1.0_Dockerfile
    runtimes_frameworks_vitepress_1.4.0_Dockerfile["vitepress-1.4.0"]
    node.js_20 --> runtimes_frameworks_vitepress_1.4.0_Dockerfile
    runtimes_languages_node.js_22_Dockerfile["node.js-22"]
    debian_ssh_12.6 --> runtimes_languages_node.js_22_Dockerfile
    runtimes_services_mcp_python-3-12_Dockerfile["mcp-python-3-12"]
    debian_ssh_12.6 --> runtimes_services_mcp_python-3-12_Dockerfile
    runtimes_frameworks_django_4.2.16_Dockerfile["django-4.2.16"]
    python_3.12 --> runtimes_frameworks_django_4.2.16_Dockerfile
    runtimes_frameworks_sealaf_1.0.0_Dockerfile["sealaf-1.0.0"]
    node.js_20 --> runtimes_frameworks_sealaf_1.0.0_Dockerfile
    runtimes_languages_node.js_20_Dockerfile["node.js-20"]
    debian_ssh_12.6 --> runtimes_languages_node.js_20_Dockerfile
    runtimes_languages_php_7.4_Dockerfile["php-7.4"]
    debian_ssh_12.6 --> runtimes_languages_php_7.4_Dockerfile
```
