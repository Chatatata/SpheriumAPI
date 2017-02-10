### Spherium Web Service REST API Developer Documentation

Lead maintainer: **Buğra Ekuklu (Chatatata)**.

# Authorization

#### Motivation
Authorization principles manage users correspondence in access of server resources.
It provides a granular control over resources via specific DSL without losing optimization opportunities and performance.

#### Implementation
Authorization stage of the pipeline consists of two substages. 
These two substages called *pre-hook* and *post-hook*. 
*Pre-hooks* are represented/implemented by policies, whereas *post-hooks* are implemented inside endpoint controllers.
The reason underneath having two substages is the concern of performance optimizations. 
*Pre-hooks* do not connect to any of the data sources (RDBS, memory-based cache), they are completely stateless and transaction-safe.
On the other hand, *post-hooks* are components of the corresponding controllers with their provided *DSLs*.

## Permissions mechanism
![Permission Set vs. User](https://s3.amazonaws.com/spherium-web-service-documentation/Permission+Set+vs.+User.png)
Each endpoint has corresponding static permissions. 
Those permissions are setup in compile-time, they cannot be changed dynamically.
Before a connection reaches to the dedicated controller handler, it is assessed by an authorization plug, which evaluates hostile user of the incoming connection.

### Permission sets
Permissions and users are bind to each other, but not directly. 
Instead, permission sets define set of permissions, hence might be aliased as *user groups*, and users are bind to those permission sets. 
User entity has *cardinality* of **nothing or one** to the permission set.

### Activation of a user
Initially, users are created without any permission sets assigned to them.
Upon a successful activation action of a user, it becomes an assignee of the default permission set.

## Managing permission sets
Users who have control over permission sets may define (or redefine) permission sets with API endpoints using *AIM (Authorization Infrastructure Management)* language.
It is refined to work with authorization artifacts in a straightforward way.
For example, if we are ought to define a new permission set, which controls authentication attempts, it would be done like so:

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
