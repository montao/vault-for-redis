## hello-vault-redis
The purpose of this project is to
- Deploy a Vault instance;
- store some credentials; and
- inject them into Redis’ AUTH. 
Users and services need the password stored in Vault to authenticate to your Redis.)
Vault is a secrets manager that can safely store secrets needed by infrastructure services and applications (e.g., database credentials) and even inject it into other services.

### Usage
Start a vault-dev instance and a redis instance by running ``sample-app/run.sh``.  
View logs by ``docker-compose logs -f``.  
The log should say ``Success! Data are written to: database/rotate-root/my-redis-database``.  
Run the tests ``sample-app/run-test.sh``.  


#### Discussion
What matters to me as a software professional are practices and principles such as simplicity, correctness (sometimes simplicity and correctness are a trade-off), testability, clean code with minimal verifiable self-contained examples for demonstration purposes, and the ideas are as easy to explain and communicate. 

#### Practical aspects 
The easiest way to run it and test it is by code pipeline with the GitHub action (but that requires a GitHub actions environment). What the project does and how it runs should be self-explanatory or at least cause minimal misunderstandings or confusion with as little effort as possible. The project should be 100% complete since the last 1% could take 90% of the effort. This time, I found that the permissions in Redis took longer than expected to get right. 


- Deployment target: Docker compose. The advantage is the simplicity and that it is available on many systems and can be run from the CI/CD such as GHA and a local environment. 

- Redis is portable and easy to start. A significant drawback is that usernames are not customizable with the Vault Redis plugin. Redis uses a permissions model that is not simple, and the documentation and syntax of the ACLs are not good enough. Several third-party open-source plugin implementations with different syntaxes can get mixed up and cause errors. 
