Static Site Generator using Make, Bash, Python & Pandoc
=======================================================

Just some rough ideas - work in progress.

Example Project Stucture
------------------------
```
.
├── assets
│   └── styles.css
├── Makefile
├── partials
│   ├── content
│   │   ├── f1.html
│   │   ├── f2.html
│   │   └── f3.html
│   └── sidebar.html
├── scripts
│   └── build.py
├── site
│   ├── assets
│   │   └── styles-e3308df2c5.css
│   ├── f1
│   │   └── index.html
│   ├── f2
│   │   └── index.html
│   ├── f3
│   │   └── index.html
│   └── images
├── src
│   ├── f1.md
│   ├── f2.md
│   ├── f3.md
│   └── fixed-elements
│       └── sidebar.md
└── templates
    └── base.html
```

Put Markdown files in `src`, JavaScript & CSS in `assets`.

For fixed elements like sidebars, see how `src/fixed-elements/sidebar.md` is built using `partials/sidebar.html` and added into the other partials using `scripts/build.py`.

This approach requires partial content to be stored in `partials` - reduces the amount of building required, at the cost of additional storage and a bit of extra complexity.
