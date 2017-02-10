### Spherium Web Service REST API Developer Documentation

Lead maintainer: **Buğra Ekuklu (Chatatata)**.

# The *AIM* Language

#### Features
AIM language is a *domain-specific data manipulation language (DSDML)* refined for manage infrastructure of authorization mechanism of the web service.
It stands for *Authorization Infrastructure Management*.
It is *multi-paradigm* and *restrictively declarative*.
The syntax consists of static clauses, making it simple to define such permission set.

```
CREATE PERMISSION SET attempt_manager
WITH DESCRIPTION "Reviews authentication attempts."
USING DEFINITION
  INCLUDE ENDPOINT SET Spherium.AttemptsController (
    REGISTER INDEX AS all
    REGISTER SHOW AS all
  )
  
  INCLUDE PERMISSION SET default
```

The language itself is stack-based, it defines authorization artifacts with including and excluding existing artifacts.

It may use specific endpoints, endpoint sets or existing permission sets in order to specify newly created permission set or alter existing ones.

#### Using language server
