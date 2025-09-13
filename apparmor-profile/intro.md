# Introduction

In this scenario, you will learn how to use custom AppArmor profiles to enforce strict security policies on containers. The scenario has two objectives:

1. Deny all write operations within a container, such as `touch` to create a new file.
2. Prevent the container from executing `chmod` commands to change file permissions or ownership.

By the end of this exercise, you will understand how to create and apply AppArmor profiles that can restrict specific behaviors in containers, enhancing your cluster's security posture.
