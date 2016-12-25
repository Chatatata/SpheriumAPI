# Authentication

> Written by **Buğra Ekuklu (Chatatata)**.

#### Why authentication is required?
Spherium is a personal learning platform, it uses usage related information in order to supply precise data to the customers. The data of the users and its availability matters. Therefore, in order to make some actions, Spherium needs to authenticate the user. Therefore, due to philosophical and technical reasons, it provides a layer of access control.

The web service utilizes two-factor authentication (2FA) mechanism and it requires three steps of authentication to be successfully completed to authorize to the application.

#### Artifacts of authentication
Several authentication artifacts are used during the process.
* **Username/E-mail**: This artifact is a property of user. It uniquely identifies its owner. It may contain sensitive data.
* **Password**: This artifact is a property of user. It should be used carefully since it will probably contain sensitive data of the user. It is persisted in back-end storage layer as hashed with either **bcrypt** or **pbkdf2** etc.
* **One-Time-Code**: This artifact is generated on the server dynamically and constitutes the second factor of authentication. It is an unsigned integer value between 100.000 and 1.000.000 inclusive from start, excluding the end.
* **Passphrase**: This artifact provides an ability to grant access on the server. It has long expiration of time and it could be stored in a device. A valid passphrase will be adequate to grant access to a user.
* **JSON Web Token**: This is a standardized artifact, according to **RFC 7519**. It contains user data, which provides stateless authentication. In many circumstances, the payload of this artifact could be read by client application, but not mutated. In case of mutation, it will invalidate itself.

#### Authentication workflow
There are three steps to perform the authentication successfully.
1. Requesting a one-time-code.
  * The reason underneath requesting an OTC is making one of the credentials to access to the web service dynamic. Usernames, emails and passwords are all static type of data. However, OTC is generated on the server dynamically per request, making itself dynamic.
  * Generally, OTC's have short expiration times (or time-to-live = *TTL*). This web service is configured to examine OTC tokens with an expiration time of **180 seconds**.
2. Requesting a passphrase (which includes a passkey) with OTC.
  * Passphrases are 86-digit access tokens which provides a unique access authority to the server. This abstraction layer is needed since usernames and passwords may contain sensitive data of a user, these artifacts could not be persisted in client-side. However, passphrases could be securely persisted, it is generated in the server randomly and has no relation with user's data.
  * Supplying a correct OTC to the server, the two-factor authentication becomes completed. Henceforth, the user should not be informed about the ongoing process, since no additional information will be requested.
  * Passphrases have longer expiration times compared to other authentication artifacts. This web service is configured to examine passphrases with an expiration time of **5 months**. One important thing about these artifacts is they could be manually invalidated by owner user or certain authorities, making them useless. Since this artifact is the smallest matter of access to the server resources, in case of misuse, it may lead to catastrophic circumstances.
  * Passphrases are generated uniquely, they are not pooled: One invalidated/expelled could not refer an access to such user.
3. Requesting a JSON Web Token *(JWT)* with a passphrase.
  * JWTs contain a payload, which carries the user information, providing a stateless authentication opportunity to the server. It could be decoded also in the client application, but not manipulated.
  * As it is said, being provided by the response upon creation of the token, the default value of expiration of a JWT is **30 minutes**. It is not a good idea to rely on that specific amount of time, however, one should understand the expiration of the token will be the amount provided.

#### Steps to authenticate to the web server
1. The server is challenged with user credentials, since device (or particular front-end application) is
  * not registered yet, or
  * registered but its passphrase is expired.

  ```
  POST /api/access_control/authentication/one_time_codes

  {
    "credentials": {
      "username": "exampleaccount",
      "password": "cleartext-password"
    }
  }
  ```

  This will return `201 Created` in normal circumstances. The user will be soon get an text message (SMS) including the OTC.

2. The server is requested to generate a passphrase.

  ```
  POST /api/access_control/authentication/passphrases

  {
    "code": 422765
  }
  ```

  This will return `201 Created` in normal circumstances with a passphrase.

3. The server is requested to generate a JWT.

  ```
  POST /api/access_control/authentication/tokens

  {
    "passkey": "HLaan+8HTy6RAnv4IopuasNKDaJLXkhdhlqJCDjw+eEh/TZgDlBOOIKAisfHkeQK00qbV0+3Tj600YdlPVnKOA"
  }
  ```

  This will return `201 Created` with a JWT and some extra information about that token. You need to supply this token in 'Authorization' header field of your HTTP requests with format `Bearer <JWT>`.

4. Server is accessed from a protected route.

  ```
  GET /api/access_control/authentication/attempts
  ..
  Authorization: Bearer HLaan+8HTy6RAnv4IopuasNKDaJLXkhdhlqJCDjw+eEh/TZgDlBOOIKAisfHkeQK00qbV0+3Tj600YdlPVnKOA
  ..

  ```
