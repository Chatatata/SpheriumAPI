### Spherium Web Service REST API Developer Documentation

Lead maintainer: **Buğra Ekuklu (Chatatata)**.

# Control of Client Access

#### Basics
Requests are treated as events, and they may mutate data on the server, or not, however these events will trigger various operations in the server, hence they are fundamentally *Remote Procedure Calls (RPC)*, resulting in either creation or transmitting of data. 
Those actions are predefined and constrained at the development stage of the API.

#### Access Control Pipeline

![Access Control Pipeline](https://s3.amazonaws.com/spherium-web-service-documentation/Access+Control+Pipeline.png)

##### Authentication
In order to enumerate users of the application, each user is matched with corresponding object.
This mechanism is initiated by registration event.
The API secures nearly all of its endpoints with authentication, meaning in order to establish access, client is expected to provide valid user credentials.
The validity of the user credentials is determined by one-way comparison of user data provided by former requests of a such client, taken from users.

##### Authorization
Resources might be restricted to a specific user, or a group. 
Authorization layer is post-hooked to the *authentication* layer, triggered if and only if that layer succeeds. 
Authorization may prevent resource from being accessed, or it might limit its amount or some property.
