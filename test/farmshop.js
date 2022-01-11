const Farmshop = artifacts.require("Farmshop");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Farmshop", function (accounts) {
  const [admin, seller, customer] = accounts;
  let instance
  beforeEach(async () => {
    instance = await Farmshop.deployed();
  });

  it("should have an admin", async function () {
    const isAdmin = await instance.isAdmin(admin);
    assert(isAdmin,true,'No Admin Found');
  });

  describe("Registered Sellers", () =>{
    let result

    before(async()=>{
      result = await instance.registerSeller("Nish","15 AeroSpace Road Mumbai", "nish@test.com",seller,{from:admin})
    })
  it("should assign the seller role", async function(){ 
    const isSeller = await instance.isSeller(seller);
    assert.equal(isSeller,true,"Seller is not registered");
    })
  it("should add user to registered sellers", async function(){ 
   const sellerCount= await instance.sellerCount();
   const rSellers = await instance.registeredSellers.call(sellerCount);
   const isSeller = await instance.isSeller(seller);
   assert.equal(isSeller,true,"Seller is not registered");
   assert.equal(rSellers.sellerAddress,seller,"Address of the seller does not match the expected value");
   assert.equal(rSellers.sellerName,'Nish',"Name of the seller does not match the expected value");
   assert.equal(rSellers.sellerPostalAddress,'15 AeroSpace Road Mumbai',"Postal Address of the seller does not match the expected value");
   assert.equal(rSellers.sellerEmail,'nish@test.com',"Email of the seller does not match the expected value");
   assert.equal(rSellers.rating.toString(),'0',"Rating of the seller does not match the expected value");
  })

  })

  describe("Registered Customers", () =>{
    let result

    before(async()=>{
      result = await instance.registerCustomer("Meera","15 Station Road Pune", "meera@test.com",{from:customer})
    })
    it("should assign the customer role", async function(){ 
      const isCustomer = await instance.isCustomer(customer);
      assert.equal(isCustomer,true,"Seller is not registered");
      })
  it("should add user to registered customers", async function(){ 
   const customerCount = await instance.customerCount();
   const rCustomers= await instance.registeredCustomers(customerCount);
   assert.equal(rCustomers.customerAddress,customer,"Address of the customer does not match the expected value");
   assert.equal(rCustomers.customerName,'Meera',"Name of the customer does not match the expected value");
   assert.equal(rCustomers.customerPostalAddress,'15 Station Road Pune',"Postal Address of the customer does not match the expected value");
   assert.equal(rCustomers.customerEmail,'meera@test.com',"Email of the customer does not match the expected value");
  })

  })

  describe("Adding Produce", () =>{
    let result;
    let produceCount;

    before(async()=>{
      result = await instance.addProduce("Cauliflower",web3.utils.toWei(".005", "Ether"),10,{from:seller});      
      produceCount= await instance.produceCount();
     
    })
    it("should increment produceCount", async function(){
     assert.equal(produceCount,1, "Adding produce should increase produce count");
    })

  it("should add item to produce", async function(){ 

   const addedProduce= await instance.produceList(produceCount);
   assert.equal(addedProduce.id.toNumber(),produceCount.toNumber(),"ID of produce does not match the expected value");
   assert.equal(addedProduce.name,"Cauliflower","Name of the produce does not match the expected value");
   assert.equal(addedProduce.price,web3.utils.toWei(".005", "Ether"),"Price of the produce does not match the expected value");
   assert.equal(addedProduce.quantity.toString(),10,"Quantity of the produce does not match the expected value");
   assert.equal(addedProduce.seller,seller,"Seller of the produce does not match the expected value");
  })
  })
  describe("Purchase Produce", () =>{
    let result;
    let produceCount;
    let orderCount;

    before(async()=>{
      produceCount = await instance.produceCount();
      let orderPrice = web3.utils.toWei(".025",'Ether');
      result = await instance.purchaseProduce(produceCount,5,{from:customer,value:orderPrice});
      orderCount = await instance.orderCount();
    })
    it("should decrease the available quantity", async function(){
     const produce= await instance.produceList(produceCount);
     assert.equal(produce.quantity,5, "Purchasing produce should decrease produce quantity");
    })
    it("should add produce to customer order", async function(){
      const customerOrder= await instance.customerOrders(orderCount);
      assert.equal(customerOrder.customer,customer, "Produce should be added to customer order");
     })

  })
});
