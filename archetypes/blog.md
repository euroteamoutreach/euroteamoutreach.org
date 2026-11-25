---
title: "{{ replace (replaceRE `^\d{4}-\d{2}-\d{2}-` `` .File.ContentBaseName) `-` ` ` | title }}"
date: {{ .Date }}
draft: true
description: >-
  TODO: The paragraph the email and the article card show, usually the opening paragraph.
tags: []
cover: ""
caption: ""
slug: "{{ .File.ContentBaseName }}"
aliases: []
---
