# X·S·L·T Shrine Generator

A very lightweight and oldweb static site generator, mainly targeted
at eliminating the need for `<iframe>` headers and footers without
substantially changing the authoring flow.

## Features

- Really simple shrine generation

- One command: `make`

## Prerequisites

These things come pre·installed on many platforms :—

- G·N·U `make` (run `make --version` to see if it is installed)
- `xsltproc` (run `xsltproc --version` to see if it is installed)

You will also need to know how to write X·M·L, and how to navigate to a
directory via the command line and run `make`.

Finally, you will need a copy of this repository, which serves as a
template.

## Basic Usage

In the `sources/` directory, create X·M·L files containing the unique
content of your pages. Generally you will want a general landing page
called `index.xml`, and a variety of other subpages. The root element
of these files should typically be an H·T·M·L `<article>` element
(remember to declare the X·H·T·M·L namespace!), and you should give it
a `@lang` attribute as well. An example is provided.

The `@data-shrine-header` and `@data-shrine-footer` attributes on the
root elements of your pages specify the names of the header and footer
to use on the page. You can use headers and footers to supply page
navigation, branding, and so forth. For each header and footer you
specify, you will need to create a corresponding `$-header.xml` or
`$-footer.xml` (where `$` is the header/footer name) which provides
the contents. These files should be placed in *this* (repository root)
directory, not in `sources/`.

The `template.xml` file in this directory contains the main page
template, and you should edit it to add styling and so forth to your
page. The `<shrine-header>`, `<shrine-content>`, and `<shrine-footer>`
elements will be replaced by the page header, content, and footer,
respectively.

Finally, just run `make` from this directory, and H·T·M·L files
corresponding to your source files will be created in the `public/`
directory (which you can then serve statically from your server).

## Notes

- The created files have a `.html` extension and need to be served
  with a `text/html` media type.

- Files at `sources/index.xml` and `sources/index-*.xml` will produce
  output at `public/%.html` (where `%` is the filename).

- All other files at `sources/*.xml` and `sources/*/*.xml` will produce
  output at `public/%/index.html` (where `%` is the filename and
  optional subdirectory). Only one level of subdirectory is supported.

- The transformation doesn’t do any rewriting of links. Make sure you
  write them to point to the *final* location of the files, not their
  location within the `sources/` directory.

- Any `@data-*` attributes (other than `@data-shrine-*` attributes) you
  add to the root (`<article>`) element will be copied onto the root
  (`<html>`) element of the template, as will `@lang` and `@xml:lang`.
  You can use this to help configure page‐specific styling.

- You can insert content into the `<head>` of the template by setting
  `@slot="shrine-head"` on the appropriate elements. For example, one
  might customize the title of a page like
  `<title slot="shrine-head">My Title | My Cool Shrine</title>`.

- If you delete files from `sources/`, the corresponding files in
  `public/` will **not** be deleted and will need to be manually
  removed. An easy way to ensure that there are no outdated files in
  `public/` is just to delete the entire directory before running
  `make`.

- This repository is intended as a starting point; feel free to
  customize it to your needs!
