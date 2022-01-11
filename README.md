**Online Farm Shop**
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
3. The customer add the quantity required and click buy.
4. The app calculates the price they need to pay and deducts from thier account and transfers to the seller's account.
5. The customers can see thier order in the My orders tab.

## Directory Structure
1. client: front-end files
2. build/contracts: ABI files
3. contracts: smart contracts
4. test: test javascript file