### Spherium Web Service REST API Developer Documentation

Lead maintainer: **Buğra Ekuklu (Chatatata)**.

# Authorization

#### Motivation
Authorization principles manage users correspondence in access of server resources.
It provides a granular control over resources without losing optimization opportunities and performance.

#### Implementation
Authorization stage of the pipeline consists of two substages. 
These two substages called *pre-hook* and *post-hook*. 
*Pre-hooks* are represented/implemented by policies, whereas *post-hooks* are implemented inside endpoint controllers.
The reason underneath having two substages is the concern of performance optimizations. 
*Pre-hooks* do not connect to any of the data sources (RDBS, memory-based cache), they are completely stateless and transaction-safe.
On the other hand, *post-hooks* are components of the corresponding controllers with their provided *DSLs*.

#### Permissions mechanism
Each endpoint has corresponding static permissions. 
Those permissions are setup in compile-time, they cannot be changed dynamically.
Before a connection reaches to the dedicated controller handler, it is assessed by an authorization plug, which evaluates hostile user of the incoming connection.

#### Permission sets
Permissions and users are bind to each other, but not directly. 
Instead, permission sets define set of permissions, hence might be aliased as *user groups*, and users are bind to those permission sets. User entity has *cardinality* of **nothing or one** to the permission set.
If user has no attached permission set, that means the user has not activated yet.
