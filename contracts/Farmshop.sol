// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Farmshop {
    uint256 produceCount = 0;
    mapping(address => RegisteredSeller) registeredSellers;
    mapping(address => RegisteredCustomers) registeredCustomers;
    mapping(uint256 => Produce) produceList;
    mapping(address => mapping(uint256 => Produce)) customerItems;

    struct Produce {
        uint256 id;
        string name;
        uint256 price;
        uint256 quantity;
        address payable seller;
    }

    struct RegisteredSeller {
        address sellerAddress;
        string sellerName;
        string sellerPostalAddress;
        string sellerEmail;
        uint256 rating;
    }

    struct RegisteredCustomers {
        address customerAddress;
        string customerName;
        string customerPostalAddress;
        string customerEmail;
    }

    event SellerRegistered(
        address sellerAddress,
        string sellerName,
        string sellerPostalAddress,
        string sellerEmail,
        uint256 rating
    );
    event customerRegistered(
        address customerAddress,
        string customerName,
        string customerPostalAddress,
        string customerEmail
    );
    event ProduceAdded(
        uint256 id,
        string name,
        uint256 price,
        uint256 quantity,
        address payable seller
    );
    event ProductPurchased(
        uint256 id,
        string name,
        uint256 price,
        address payable seller
    );

    function registerSeller(
        string memory _sellerName,
        string memory _postalAddress,
        string memory _sellerEmail
    ) public {
        //check name is valid
        require(bytes(_sellerName).length > 0, "Name cannot be null");
        //check contact email is valid
        require(bytes(_sellerEmail).length > 0, "Contact email cannot be null");
        //Create a Seller
        registeredSellers[msg.sender] = RegisteredSeller(
            msg.sender,
            _sellerName,
            _postalAddress,
            _sellerEmail,
            0
        );
        //Emit Event
        emit SellerRegistered(
            msg.sender,
            _sellerName,
            _postalAddress,
            _sellerEmail,
            0
        );
    }

    function registerCustomer(
        string memory _customerName,
        string memory _postalAddress,
        string memory _customerEmail
    ) public {
        //check name is valid
        require(
            bytes(_customerName).length > 0,
            "Customer name cannot be null"
        );
        //check contact email is valid
        require(
            bytes(_customerEmail).length > 0,
            "Customer email cannot be null"
        );
        //check postal address is valid
        require(
            bytes(_postalAddress).length > 0,
            "Customer postal address cannot be null"
        );
        //Create a Seller
        registeredCustomers[msg.sender] = RegisteredCustomers(
            msg.sender,
            _customerName,
            _postalAddress,
            _customerEmail
        );
        //Emit Event
        emit customerRegistered(
            msg.sender,
            _customerName,
            _postalAddress,
            _customerEmail
        );
    }

    function addProduce(
        string memory _name,
        uint256 _price,
        uint256 _quantity
    ) public {
        //check if person adding is registred
        require(
            registeredSellers[msg.sender].sellerAddress == msg.sender,
            "User is not registered as a seller"
        );
        //check if price is valid
        require(_price > 0, "Price cannot be 0");
        //check if quantity is valid
        require(_quantity > 0, "Price cannot be 0");
        //add product
        produceList[produceCount] = Produce(
            produceCount,
            _name,
            _price,
            _quantity,
            msg.sender
        );
        //increment product counter
        produceCount++;
        //emit event
        emit ProduceAdded(produceCount, _name, _price, _quantity, msg.sender);
    }

    function purchaseProduce(uint256 _produceID, uint256 _quantity)
        public
        payable
    {
        // check customer is registered
        require(
            registeredCustomers[msg.sender].customerAddress == msg.sender,
            "User is not registered as customer"
        );
        //check if msg.value is enough to buy produce
        require(msg.value >= produceList[_produceID].price);
        //check if there is enough quanity to buy
        require(
            produceList[_produceID].quantity >= _quantity,
            "Not enough quantity"
        );
        //check if buyer is not the seller
        require(produceList[_produceID].seller != msg.sender);

        //add to the customerItems mappings
        customerItems[msg.sender][_produceID] = produceList[_produceID];

        //reduce the quantity available
        produceList[_produceID].quantity--;

        //transfer ether to seller
        address(produceList[_produceID].seller).transfer(msg.value);

        //emit event
        emit ProductPurchased(
            _produceID,
            produceList[_produceID].name,
            produceList[_produceID].price,
            produceList[_produceID].seller
        );
    }

    function giveSellerRating(
        address _sellerAddress,
        uint256 _rating,
        uint256 _produceID
    ) public returns (uint256) {
        //check if the address giving rating is not the seller
        require(
            produceList[_produceID].seller != msg.sender,
            "Seller cannot rate themselves"
        );
        //check if the customer has bought the product from the seller
        require(
            customerItems[msg.sender][_produceID].seller == _sellerAddress,
            "Customer needs to buy the product before leaving review"
        );

        //check if rating is not greater than 5
        require(_rating <= 5, "Rating cannot be more than 5");

        //add rating
        registeredSellers[_sellerAddress].rating = _rating;

        //return rating
        registeredSellers[_sellerAddress].rating;
    }
}
