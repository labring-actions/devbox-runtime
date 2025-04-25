-- init tag
INSERT INTO
    "Tag" (name, "enName", "zhName", type)
VALUES
    (
        'javascript',
        'Javascript',
        'Javascript',
        'PROGRAMMING_LANGUAGE'
    ),
    ('csharp', 'C#', 'C#', 'PROGRAMMING_LANGUAGE'),
    (
        'python',
        'Python',
        'Python',
        'PROGRAMMING_LANGUAGE'
    ),
    (
        'golang',
        'Golang',
        'Golang',
        'PROGRAMMING_LANGUAGE'
    ),
    ('c', 'C', 'C', 'PROGRAMMING_LANGUAGE'),
    ('rust', 'Rust', 'Rust', 'PROGRAMMING_LANGUAGE'),
    ('cpp', 'C++', 'C++', 'PROGRAMMING_LANGUAGE'),
    ('ruby', 'Ruby', 'Ruby', 'PROGRAMMING_LANGUAGE'),
    ('java', 'Java', 'Java', 'PROGRAMMING_LANGUAGE'),
    ('php', 'Php', 'Php', 'PROGRAMMING_LANGUAGE'),
    ('ai', 'AI', 'AI', 'USE_CASE'),
    ('os', 'OS', '操作系统', 'USE_CASE'),
    ('tool', 'Tool', '工具', 'USE_CASE'),
    ('blog', 'Blog', '博客', 'USE_CASE'),
    (
        'OFFICIAL_CONTENT',
        'MCP',
        'MCP',
        'OFFICIAL_CONTENT'
    ),
    (
        'official',
        'Official Picks',
        '官方精选',
        'OFFICIAL_CONTENT'
    );
