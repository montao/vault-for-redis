## hello-vault-redis
The purpose of this project is to
- Deploy a Vault instance;
- store some credentials; and
- inject them into Redis’ AUTH. 
Users and services need the password stored in Vault to authenticate to your Redis.)
Vault is a secrets manager that can safely store secrets needed by infrastructure services and applications (e.g., database credentials) and even inject it into other services.

## Overview of steps

1/ As deployment target: I’ve chosen docker compose. The advantages are its relative simplicity and availability for CI/CD pipeline testing. The docker engine can be run locally, and the script is provided to start two docker containers, one for Redis and one for Vault. 

2/ As a service to inject the secrets to, I’ve chosen Redis. The advantages of Redis is its relatively high level of capability of security settings with ACLs, compared to a more simplistic cache (e.g. memcache) but the drawback is that Redis becomes more complicated to configure compared to, for example, memcached or ElasticSearch. 

3/ The Vault instance can be started from the script named run.sh in dev mode. 

4/ When the instance is started, it generates credentials. This script is named entrypoint.sh

5/ The credentials are injected into Redis and are updateable in Vault. The test is named ./run-tests.sh 

7/ The PKI engine is initiated in entrypoint.sh, but is incomplete at this time of writing.


### Usage
Start a vault-dev instance and a redis instance by running ``app/run.sh``.  
View logs by ``docker-compose logs -f``.  
The log should say ``Success! Data are written to: database/rotate-root/my-redis-database``.  
Run the tests ``app/run-test.sh``.  
A successful test should print output similar to the following.  
```
% ./run-tests.sh
[+] Running 5/5
 ✔ Network app_default           Created                                                           0.0s 
 ✔ Volume "app_cache"            Created                                                           0.0s 
 ✔ Container app-cache-1         Healthy                                                          30.8s 
 ✔ Container app-vault-server-1  Healthy                                                          37.4s 
 ✔ Container app-healthy-1       Started                                                          37.5s 
[TEST 1]: output: WRONGPASS invalid username-password pair or user is disabled.
[TEST 1]: OK
[TEST 2]: output: Success! Data written to: database/rotate-root/my-redis-database
[TEST 2]: OK
[TEST 3]: output: Key                Value
---                -----
lease_id           database/creds/my-dynamic-role/oO0363BMdRHiyr04Q65PaokB
lease_duration     15m
lease_renewable    true
password           yjt-vYDIDj7cCoX6siEX
username           V_TOKEN_MY-DYNAMIC-ROLE_0X6OLNAVIS0ITQUZWNNL_1693722342
[TEST 4]: username: V_TOKEN_MY-DYNAMIC-ROLE_JS5YBGHTRIQVKL5TYUCK_1693722343
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
OK
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
TESTED BY V_TOKEN_MY-ALL-ROLE_116H9CTTU2GVUVHK20VE_1693722343 SUCCESSFULLY!
[+] Running 5/5
 ✔ Container app-healthy-1       Removed                                                           0.0s 
 ✔ Container app-vault-server-1  Removed                                                           0.1s 
 ✔ Container app-cache-1         Removed                                                           0.1s 
 ✔ Volume app_cache              Removed                                                           0.0s 
 ✔ Network app_default           Removed                                                           0.0s 
```

#### Discussion
What matters to me as a software professional are practices and principles such as simplicity: A simple solution is often better than trying to be perfect. Important features are portability and reproducibility, correctness (sometimes simplicity and correctness are a trade-off), testability, clean code with minimal verifiable reproducible **self-contained** examples for demonstration purposes, and the ideas are as easy to explain and communicate. 

#### Practical aspects 
The easiest way to run it and test it is by code pipeline with the GitHub action (but that requires a GitHub actions environment). What the project does and how it runs should be self-explanatory or at least cause minimal misunderstandings or confusion with as little effort as possible. The project should be 100% complete since the last 1% could take 90% of the effort. This time, I found that the permissions in Redis took longer than expected to get right.  

Note the line ``host="cache"`` (not ``host="localhost"``) for the Redis host:
```
vault write database/config/my-redis-database \
  plugin_name="redis-database-plugin" \
  host="cache" \
  port=6379 \
  tls=false \
  ca_cert="$CACERT" \
  username="default" \
  password="pass" \
  allowed_roles="my-*-role"
```

- Deployment target: Docker compose. The advantage is the simplicity and that it is available on many systems and can be run from the CI/CD such as GHA and a local environment. 

- Redis is portable and easy to start. A significant drawback is that usernames are not customizable with the Vault Redis plugin. Redis uses a permissions model that is not simple, and the documentation and syntax of the ACLs are not good enough. Several third-party open-source plugin implementations with different syntaxes can get mixed up and cause errors. 

#### Future work
Use Terraform. Deploy to a cloud provider e.g., AWS, GCP, or Azure. Discuss the benefit of using e.g., Kubernetes or Fargate instead of plain Docker. Discuss if a real programming language is better than (ba)sh, and if new code should be written in (ba)sh at all.


