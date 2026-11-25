---
title: "{{ replace (replaceRE `^\d{4}-\d{2}-\d{2}-` `` .File.ContentBaseName) `-` ` ` | title }}"
date: {{ with findRE `^\d{4}-\d{2}-\d{2}` .File.ContentBaseName 1 }}{{ index . 0 }}{{ else }}{{ now.Format "2006-01-02" }}{{ end }}
draft: true
description: >-
  TODO: The paragraph the email and the article card show, usually the opening paragraph.
tags: []
cover: ""
caption: ""
slug: "{{ .File.ContentBaseName }}"
aliases: []
---
