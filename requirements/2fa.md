## Two-factor Authentication

### Use case scenario:
* User provides credential, web service makes an RPC call to remote embedded device.
* User provides OTC, web service generates a unique passkey.

#### Alternative Flows
* OTC has time-to-live (TTL) of *3 minutes*.
* Nested OTC requests will override existing ones.
* User is not able to make more than 2 OTC requests in *15 minutes*.
* An incorrect challenging of OTC response will invalidate the OTC request immediately.
* User may not have two OTC openings at the same time.
* Two incorrect OTC response will make account inauthorizable for **X** hours. Subsequent responses after ban will make the account remain same without manual unban.
