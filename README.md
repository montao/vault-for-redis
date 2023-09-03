## vault-for-redis

### Motivation
There is a need to safely store secrets for infrastructure services and applications (e.g., database credentials) and even inject them into other services. The purpose here is to show a minimal, **self-contained** example that will
- Deploy a containerized instance of the Vault secrets manager;
- store some credentials; and
- inject them into the Redis’ AUTH of a containerized Redis instance
  
Users and services will then need the password stored in Vault to authenticate to Redis.

### Usage
Start the vault-dev and Redis instances by running ``app/run.sh``.  
View logs by ``docker-compose logs -f``.  
The log should say ``Success! Data are written to database/rotate-root/my-redis-database``.  
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
What matters to me as a software professional are practices and principles such as simplicity, correctness (sometimes simplicity and correctness are a trade-off), testability, clean code with minimal verifiable self-contained examples for demonstration purposes, and the ideas are as easy to explain and communicate. 

#### Practical aspects 
The easiest way to run it and test it is by code pipeline with the GitHub action (but that requires a GitHub actions environment). What the project does and how it runs should be self-explanatory or at least cause minimal misunderstandings or confusion with as little effort as possible. The project should be 100% complete since the last 1% could take 90% of the effort. This time, I found that the permissions in Redis took longer than expected to get right. 


- Deployment target: Docker compose. The advantage is the simplicity and that it is available on many systems and can be run from the CI/CD such as GHA and a local environment. 

- Redis is portable and easy to start. A significant drawback is that usernames are not customizable with the Vault Redis plugin. Redis uses a permissions model that is complex, and the documentation and syntax of the ACLs need to be better. Several third-party open-source plugin implementations with different syntaxes can get mixed up and cause errors. 


#### Discussion
What matters to me as a software professional are practices and principles such as simplicity, correctness (sometimes simplicity and correctness are a trade-off), testability, clean code with minimal, verifiable, and **self-contained** examples for demonstration purposes, and the ideas are as easy to explain and communicate. 

#### Future work
Use Terraform. Deploy to a cloud provider e.g., AWS, GCP, or Azure. Discuss the benefit of using e.g., Kubernetes or Fargate instead of plain Docker. Discuss if a real programming language is better than (ba)sh, and if new code should be written in (ba)sh at all.


