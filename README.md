# Online Farm shop

## Prerequisites
1. Node.js >= v14
2. Truffle
3. Ganache
4. npm
5. git

### Installing Node Modules
1. Run npm install
2. All node modules are installed
3. package-lock.json created

### Contracts
1. Run local testnet in port 8545 and host 127.0.0.1 in Ganache
2. truffle migrate --network development
3. To run test run truffle test

### Frontend
1. Front end files in the client folder.
2. Running tests requires lite server which is installed as part of node modules.
3. bs-config.json contains configuration for lite server.
4. run command npm run dev
5. This opens http://localhost:3000/

## Project Description
1. The farm shop will allow farmers to sell their produce directly to consumers.
2. The farmers are registered by the admins as sellers.
3. Once farmers are registered as sellers, they are able to add their produce.
4. Any account is able to register themselves as a customer.
5. Once an account is registered as a customer, they are able to buy produce listed by the farmers.

### Registering a Seller
1. A seller can only be registered by the admin.
2. The admin is the account which has deployed the contract
### Adding Produce
1. Once the seller has been registered, they can add produce.
2. Sellers fill in the form and provide: price in Eth per kilogram and quantity available.
### Customer Registration
1. Any user can register as a customer.
2. Once registered, a customer can buy produce that have been added by the sellers.
### Buying Produce
1. Buy Produce Tab appears.
2. The customer add the quantity required and clicks buy.
3. The app calculates the price they need to pay and deducts from thier account and transfers to the seller's account.
4. The customers can see thier order in the My orders tab.
5. Seller sees all orders under the Orders tab.

## Directory Structure
1. client: front-end files
2. build/contracts: ABI files
3. contracts: smart contracts
4. migrations: Migration files for deploying the smart contracts
5. test: test javascript file