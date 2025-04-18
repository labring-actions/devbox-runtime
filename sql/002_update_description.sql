-- 更新template 简介
UPDATE public."TemplateRepository"
SET
    description = temp.new_description
FROM
    (
        VALUES
            (
                'react',
                'Facebook React Frontend Development Environment with IDE Integration'
            ),
            (
                'vue',
                'Vue.js Frontend Environment with Pre-installed Dependencies'
            ),
            (
                'angular',
                'Complete Google Angular Development Toolchain Environment'
            ),
            (
                'svelte',
                'Comprehensive Svelte Development Toolkit Package'
            ),
            (
                'astro',
                'Pre-configured Astro Build and Development Environment'
            ),
            (
                'next.js',
                'Next.js Development Runtime Environment'
            ),
            (
                'nuxt3',
                'Nuxt3 Server-Side Rendering Environment'
            ),
            (
                'umi',
                'Alibaba UMI Framework Complete Development Environment'
            ),
            (
                'docusaurus',
                'Facebook Docusaurus Documentation Development Environment'
            ),
            (
                'vitepress',
                'Vue-powered Documentation Site Development Environment'
            ),
            (
                'hugo',
                'Hugo Static Site Environment with Go Pre-installed'
            ),
            ('hexo', 'Node.js-powered Hexo Blog Environment'),
            (
                'express.js',
                'Complete Express Backend Development Environment'
            ),
            (
                'spring-boot',
                'Java + Spring Boot Development Kit'
            ),
            (
                'django',
                'Python Django Full-Stack Development Environment'
            ),
            (
                'flask',
                'Lightweight Python Web Development Environment'
            ),
            (
                'gin',
                'Go Gin Web Complete Development Environment'
            ),
            (
                'chi',
                'Go Chi HTTP Service Development Environment'
            ),
            ('echo', 'Go Echo Web Framework Environment'),
            (
                'iris',
                'Go Iris Development Toolchain Environment'
            ),
            (
                'quarkus',
                'Java Cloud-Native Development Environment'
            ),
            ('rocket', 'Rust Web Development Toolchain'),
            ('vert.x', 'JVM Reactive Development Environment'),
            (
                'python',
                'Python Language Development Runtime Environment'
            ),
            ('java', 'Java JDK Development Environment'),
            (
                'go',
                'Go Language Complete Development Toolchain'
            ),
            (
                'rust',
                'Rust Language Compilation Development Environment'
            ),
            (
                'c',
                'C Language Compilation Development Toolchain'
            ),
            (
                'cpp',
                'C++ Development and Compilation Environment'
            ),
            ('php', 'PHP Development Runtime Environment'),
            (
                'node.js',
                'Node.js Runtime Development Environment'
            ),
            ('nginx', 'Nginx Server Configuration Environment'),
            ('ubuntu', 'Ubuntu Basic Development Environment'),
            (
                'debian-ssh',
                'Debian Development Environment with SSH Support'
            ),
            ('net', '.NET Development Runtime Environment')
    ) AS temp (name, new_description)
WHERE
    "TemplateRepository".name = temp.name;
