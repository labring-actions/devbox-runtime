--更新绑定
INSERT INTO
    public."TemplateRepositoryTag" ("templateRepositoryUid", "tagUid")
SELECT
    t.uid,
    c.uid
FROM
    public."TemplateRepository" t,
    public."Tag" c
WHERE
    (
        (c.name = 'official')
        OR
        -- Programming Languages
        (
            t.name = 'python'
            AND c.name = 'python'
        )
        OR (
            t.name = 'java'
            AND c.name = 'java'
        )
        OR (
            t.name = 'rust'
            AND c.name = 'rust'
        )
        OR (
            t.name = 'cpp'
            AND c.name = 'cpp'
        )
        OR (
            t.name = 'c'
            AND c.name = 'c'
        )
        OR (
            t.name = 'go'
            AND c.name = 'golang'
        )
        OR (
            t.name = 'php'
            AND c.name = 'php'
        )
        OR
        -- JavaScript and its frameworks
        (
            t.name IN (
                'node.js',
                'express.js',
                'next.js',
                'nuxt3',
                'angular',
                'vue',
                'react',
                'svelte',
                'astro',
                'sealaf'
            )
            AND c.name = 'javascript'
        )
        OR
        -- go frameworks
        (
            t.name IN ('gin', 'iris', 'echo', 'chi')
            AND c.name = 'golang'
        )
        OR
        -- Java frameworks
        (
            t.name IN ('quarkus', 'spring-boot', 'vert.x')
            AND c.name = 'java'
        )
        OR
        -- Rust frameworks
        (
            t.name IN ('rocket')
            AND c.name = 'rust'
        )
        OR
        -- Python frameworks
        (
            t.name IN ('django', 'flask')
            AND c.name = 'python'
        )
        OR
        -- c#
        (
            t.name IN ('net')
            AND c.name = 'csharp'
        )
        OR
        -- Operating Systems
        (
            t.name IN ('debian-ssh', 'ubuntu')
            AND c.name = 'os'
        )
        OR
        -- Blog/Documentation
        (
            t.name IN ('hexo', 'docusaurus', 'hugo', 'vitepress')
            AND c.name IN ('blog', 'javascript')
        )
        OR
        -- Tools
        (
            t.name IN (
                'nginx',
                'gin',
                'chi',
                'iris',
                'echo',
                'sealaf',
                'quarkus',
                'rocket',
                'umi'
            )
            AND c.name = 'tool'
        )
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            "TemplateRepositoryTag" tc
        WHERE
            tc."templateRepositoryUid" = t.uid
            AND tc."tagUid" = c.uid
    );
