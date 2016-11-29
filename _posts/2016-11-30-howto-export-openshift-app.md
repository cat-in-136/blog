---
layout: post
title: 'Note to self: how to export a simple openshift app and restore to another project'
author: cat_in_136
tags:
- howto
- openshift
- ruby
- チラシの裏
date: '2016-11-29T00:41:21+09:00'
---

### Mission

 * [Openshift Online (Next Gen)][openshift-devpreview] account expire 30 days after registering.
 * After my account expires, I'll a new account and then a fresh set of resources is provided.
 * I wanna restore the app on resources for the new account as it is for the old account.
 * Target web application: Super simple sinatra webapp. (No Database (postgresql, mysql, ...))

### Target Webapp

app.rb, e.g.:

    require "sinatra"

    get "/" do
      "Hello, world!"
    end

Since config.ru and Gemfile are very very straight forward, they're omitted.


In my situation, I hosted these codes on *private* git repository, e.g. `git@private:repository-of/helloworldapp.git`.
(I've pushed a public key for the repository to openshift;
like described on "[Deploying From Private Git Repositories][deploying-from-private-git]")

### Prep work

Export the `buildconfig` and the public key for the app: `helloworldapp`.

    % oc export buildconfig helloworldapp -o yaml > buildconfig-helloworldapp.yaml
    % oc export secret sshsecret -o yaml > sshsecret.yaml

Note: I must do this work *before my account expires*.

### Restore app

Create new app according to the method written on the Developer Guide:
[Creating New Applications][creating-new-applications].

    % oc new-project foobar-project
    % oc new-app git@private:repository-of/helloworldapp.git

The first build will fail because of lack of the public key and any other build configuration.

    % oc create -f sshsecret.yaml
    % oc replace -f buildconfig-helloworldapp.yaml

The second build would be successed.

### Future Issues

 * Find a much more suitable method
 * Support for DB (postgresql, mysql, ...)
 * Investigate why `oc export all -o yaml > project.yaml` and `oc create -f project.yaml` does not work

[openshift-devpreview]: https://www.openshift.com/devpreview/index.html
[deploying-from-private-git]: https://blog.openshift.com/deploying-from-private-git-repositories/
[creating-new-applications]: https://docs.openshift.org/latest/dev_guide/new_app.html
