App = {
  loading: false,
  currAccount: '',
  contracts: {},

  load: async () => {
    await App.loadWeb3();
    await App.loadAccount();
    await App.loadContract();
    await App.render();
  },

  // https://medium.com/metamask/https-medium-com-metamask-breaking-change-injecting-web3-7722797916a8
  loadWeb3: async () => {
    if (typeof window.ethereum !== 'undefined') {
      console.log('window.ethereum is enabled');
      if (window.ethereum.isMetaMask === true) {
        var web3 = new Web3(window.ethereum);
      } else {
        console.log('MetaMask is not available');
      }
    } else {
      console.log('window.ethereum is not found');
    }
  },

  loadAccount: async () => {
    // Set the current blockchain account
    await ethereum.request({ method: 'eth_requestAccounts' });
    App.currAccount = ethereum.selectedAddress;
  },

  loadContract: async () => {
    // Create a JavaScript version of the smart contract
    var web3 = new Web3(window.ethereum);
    const farmshop = await $.getJSON('Farmshop.json');
    App.contracts.Farmshop = TruffleContract(farmshop);
    App.contracts.Farmshop.setProvider(window.ethereum);

    // Hydrate the smart contract with values from the blockchain
    App.farmshop = await App.contracts.Farmshop.deployed();
  },

  render: async () => {
    // Prevent double render
    if (App.loading) {
      return;
    }

    // Update app loading state
    App.setLoading(true);

    // Render Account
    $('#account').html(App.currAccount);

    //check if current user is Admin
    if (await App.farmshop.isAdmin(App.currAccount)) {
      $('#regitserSeller-tab').show();
      $('#regitserSeller-tab').attr('aria-selected',true);
      $('#regitserSeller-tab').attr('class','nav-link active');
      $('#regitserSeller').attr('class','tab-pane fade active show');

      $('#BuyProduce-tab').attr('aria-selected',false);
      $('#BuyProduce-tab').attr('class','nav-link');
      $('#BuyProduce').attr('class','tab-pane fade');
      $('#registerSeller').show();

      // Render Sellers
      await App.renderSellers();
    } else {
      $('#registerSeller-tab').hide();
      $('#regitserSeller-tab').attr('aria-selected',false);
      $('#regitserSeller-tab').attr('class','nav-link');
      $('#regitserSeller').attr('class','tab-pane fade');
      $('#registerSeller').hide();
    }

    // check if current user is seller
    if (await App.farmshop.isSeller(App.currAccount)) {
      $('#AddProduce-tab').show();      
      $('#AddProduce-tab').attr('aria-selected',true);
      $('#AddProduce-tab').attr('class','nav-link active');
      $('#AddProduce').attr('class','tab-pane fade active show');

      $('#BuyProduce-tab').attr('aria-selected',false);
      $('#BuyProduce-tab').attr('class','nav-link');
      $('#BuyProduce').attr('class','tab-pane fade');
      // Render My Produce
      await App.renderMyProduce();

      $('#SellerOrders-tab').show();
      await App.renderSellerOrders();   
    } else {
      $('#AddProduce-tab').hide();
      $('#AddProduce-tab').attr('aria-selected',false);
      $('#AddProduce-tab').attr('class','nav-link');
      $('#AddProduce').attr('class','tab-pane fade');
    }

    // check if current user is customer
    if (await App.farmshop.isCustomer(App.currAccount)) {
      await App.renderProduce();
      //Render My Orders
      await App.renderMyOrders();
      $('#myBoughtProduce-tab').show();
    } else {
      //$('#BuyProduce-tab').attr('aria-selected',true);
      //$('#BuyProduce-tab').attr('class','nav-link active');
     // $('#BuyProduce').attr('class','tab-pane fade active show');
      $('#registerCustomer').show();
      $('#myBoughtProduce-tab').hide();
    }
    // Update loading state
    App.setLoading(false);
  },

  renderSellers: async () => {
    // Load the total seller count from the blockchain
    const sellerCount = await App.farmshop.sellerCount();
    console.log(sellerCount);
    const sellerTable = $('#sellerTable');
    const sellerTableBody = $('#sellerTable tbody');
    const sellerForm = $('#sellerForm');
    // Render out each task with a new task template
    for (var i = 1; i <= sellerCount; i++) {
      // Fetch the resgistered seller data from the blockchain
      const rSellers = await App.farmshop.registeredSellers(i);
      const sellerName = rSellers.sellerName;
      const sellerEmail = rSellers.sellerEmail;
      const sellerAccount = rSellers.sellerAddress;
      const sellerPostal = rSellers.sellerPostalAddress;
      const sellerRatings = rSellers.rating.toString();

      //hide registration form if seller is already registered
      if (App.currAccount == sellerAccount.toString().toLowerCase()) {
        sellerForm.hide();
      }
      // Create the html for the sellers
      const sellerRow =
        '<tr><td>' +
        i +
        '</td><td>' +
        sellerName +
        '</td><td>' +
        sellerEmail +
        '</td><td>' +
        sellerPostal +
        '</td><td>' +
        sellerAccount +
        '</td><td>' +
        '</td><td>' +
        sellerRatings +
        '</td></tr>';

      // Put the task in the correct list
      sellerTableBody.append(sellerRow);
    }
    sellerTable.show();
  },
  renderMyProduce: async () => {
    // Load the total produce count from the blockchain
    const produceCount = await App.farmshop.produceCount();
    const produceTable = $('#MyProduceTable');
    const produceTableBody = $('#MyProduceTable tbody');
    // Render out each produce
    for (var i = 1; i <= produceCount; i++) {
      // Fetch the resgistered seller data from the blockchain
      const addedProduce = await App.farmshop.produceList(i);
      const produceSeller = addedProduce.seller;
      if (App.currAccount == produceSeller.toString().toLowerCase()) {
        const produceName = addedProduce.name;
        const producePrice = addedProduce.price / 1000000000000000000;
        const produceQuantity = addedProduce.quantity.toString();
        //const produceSeller = addedProduce.seller

        // Create the html for the produce
        const produceRow =
          '<tr><td>' +
          i +
          '</td><td>' +
          produceName +
          '</td><td>' +
          producePrice +
          '</td><td>' +
          produceQuantity +
          '</td><td>' +
          produceSeller +
          '</td></tr>';

        // Put the produce in the correct list
        produceTableBody.append(produceRow);
      }
    }
    produceTable.show();
  },
  renderProduce: async () => {
    // Load the total produce count from the blockchain
    const produceCount = await App.farmshop.produceCount();
    const produceTable = $('#ProduceTable');
    const produceTableBody = $('#ProduceTable tbody');
    // Render out each produce
    for (var i = 1; i <= produceCount; i++) {
      // Fetch the resgistered seller data from the blockchain
      const addedProduce = await App.farmshop.produceList(i);
      const produceSeller = addedProduce.seller;
      const produceName = addedProduce.name;
      const producePrice = addedProduce.price / 1000000000000000000;
      const produceQuantity = addedProduce.quantity.toString();
      //const produceSeller = addedProduce.seller

      // Create the html for the produce
      const produceRow =
        '<tr><td>' +
        i +
        '</td><td>' +
        produceName +
        '</td><td>' +
        producePrice +
        '</td><td>' +
        produceQuantity +
        '</td><td>' +
        produceSeller +
        '</td><td>' +
        '<input type="text" id=buyQuantity' +
        i +
        ' placeholder="Quantity (Kg)"></td><td>' +
        '<input type="button" id=buyButton' +
        i +
        ' value="Buy" onclick="App.buyProduct(this,' +
        i +
        ')"></td></tr>';
      // Put the produce in the correct list
      produceTableBody.append(produceRow);
    }
    produceTable.show();
  },
  renderMyOrders: async () => {
    // Load the total produce count from the blockchain
    const orderCount = await App.farmshop.orderCount();
    const ordersTable = $('#MyOrdersTable');
    const ordersTableBody = $('#MyOrdersTable tbody');
    // Render out each produce
    for (var i = 1; i <= orderCount; i++) {
      // Fetch the resgistered seller data from the blockchain
      const orderProduce = await App.farmshop.customerOrders(i);
      const orderCustomer = orderProduce.customer;
      if (App.currAccount == orderCustomer.toString().toLowerCase()) {
        const produceName = orderProduce.produceName;
        const producePrice = orderProduce.pricePaid / 1000000000000000000;
        const produceQuantity = orderProduce.quantityBought.toString();
        const produceSeller = orderProduce.seller;

        // Create the html for the produce
        const produceRow =
          '<tr><td>' +
          i +
          '</td><td>' +
          produceName +
          '</td><td>' +
          producePrice +
          '</td><td>' +
          produceQuantity +
          '</td><td>' +
          produceSeller +
          '</td></tr>';

        // Put the produce in the correct list
        ordersTableBody.append(produceRow);
      }
    }
    ordersTable.show();
  },
  renderSellerOrders: async () => {
    // Load the total produce count from the blockchain
    const orderCount = await App.farmshop.orderCount();
    const ordersTable = $('#SellerOrdersTable');
    const ordersTableBody = $('#SellerOrdersTable tbody');
    // Render out each produce
    for (var i = 1; i <= orderCount; i++) {
      // Fetch the resgistered seller data from the blockchain
      const orderProduce = await App.farmshop.customerOrders(i);
      const orderSeller = orderProduce.seller;
      if (App.currAccount == orderSeller.toString().toLowerCase()) {
        const produceName = orderProduce.produceName;
        const producePrice = orderProduce.pricePaid / 1000000000000000000;
        const produceQuantity = orderProduce.quantityBought.toString();

        // Create the html for the produce
        const produceRow =
          '<tr><td>' +
          i +
          '</td><td>' +
          produceName +
          '</td><td>' +
          producePrice +
          '</td><td>' +
          produceQuantity +
          '</td><td>' ;

        // Put the produce in the correct list
        ordersTableBody.append(produceRow);
      }
    }
    ordersTable.show();
  },
  registerSeller: async () => {
    App.setLoading(true);
    await App.farmshop.registerSeller(
      $('#sellerName').val(),
      $('#sellerEmail').val(),
      $('#sellerAddress').val(),
      $('#sellerPublicAddress').val(),
      { from: App.currAccount }
    );
    window.location.reload();
  },
  registerCustomer: async () => {
    App.setLoading(true);
    await App.farmshop.registerCustomer(
      $('#customerName').val(),
      $('#customerAddress').val(),
      $('#customerEmail').val(),
      { from: App.currAccount }
    );
    window.location.reload();
  },
  addSellerProduce: async () => {
    App.setLoading(true);
    var web3 = new Web3(window.ethereum);
    console.log($('#ProducePrice').val().toString());
    await App.farmshop.addProduce(
      $('#ProduceName').val(),
      web3.utils.toWei($('#ProducePrice').val().toString(), 'Ether'),
      $('#Quantity').val(),
      { from: App.currAccount }
    );
    window.location.reload();
  },
  buyProduct: async (obj, produceID) => {
    App.setLoading(true);
    var produceQuantity = $('#buyQuantity' + produceID).val();
    var produce = await App.farmshop.produceList(produceID);
    var orderPrice = produceQuantity * produce.price;
    await App.farmshop.purchaseProduce(produceID, produceQuantity, {
      from: App.currAccount,
      value: orderPrice,
    });
    window.location.reload();
  },
  toggleCompleted: async (e) => {
    App.setLoading(true);
    const taskId = e.target.name;
    await App.todoList.toggleCompleted(taskId);
    window.location.reload();
  },

  setLoading: (boolean) => {
    App.loading = boolean;
    const loader = $('#loader');
    const content = $('#content');
    const myProdcontent = $('#myProdcontent');
    const BuyCustomerProduce = $('#BuyCustomerProduce');
    if (boolean) {
      loader.show();
      content.hide();
      myProdcontent.hide();
      BuyCustomerProduce.hide();
    } else {
      loader.hide();
      content.show();
      myProdcontent.show();
      BuyCustomerProduce.show();
    }
  },
};

$(() => {
  $(window).load(() => {
    App.load();
  });
});
