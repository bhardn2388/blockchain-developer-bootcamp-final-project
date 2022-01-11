// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "./Security.sol";
/// @title Farmshop
/// @author Nishant Bhardwaj
/// @notice This contract allows admin to register seller, sellers to add produce, and customers to buy produce
/// @dev The contract inherits from Security.sol which inherits openzepplin AccessContro.sol
contract Farmshop is Security {
    ///@dev tracks the produce ids in the produceList mapping
    uint256 public produceCount = 0;
    ///@dev tracks the seller ids in the registeredSellers mapping
    uint256 public sellerCount = 0;
    ///@dev tracks the customer ids in the registeredCustomers mapping
    uint256 public customerCount = 0;
    ///@dev tracks the order ids in the customerOrders mapping
    uint256 public orderCount = 0;
    mapping(uint256 => RegisteredSeller) public registeredSellers;
    mapping(uint256 => RegisteredCustomers) public registeredCustomers;
    mapping(uint256 => Produce) public produceList;
    mapping(address => uint256) public sellerState;
    mapping(address => uint256) public customerState;
    mapping(uint256 => customerOrder) public customerOrders;

    struct Produce {
        uint256 id;
        string name;
        uint256 price;
        uint256 quantity;
        address payable seller;
    }
    struct customerOrder {
        string produceName;
        uint256 quantityBought;
        uint256 pricePaid;
        address customer;
        address seller;
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
   /// @notice Emitted when a seller is registered
   /// @param sellerAddress public account key of the seller.
   /// @param sellerName of the seller
   /// @param sellerPostalAddress address of the seller
   /// @param sellerEmail email of the seller
   /// @param rating rating
   /// @dev the seller rating functionality has not been implemented yet
    event SellerRegistered(
        address sellerAddress,
        string sellerName,
        string sellerPostalAddress,
        string sellerEmail,
        uint256 rating
    );
   /// @notice Emitted when a customer is registered
   /// @param customerAddress-public account key for the customer
   /// @param customerName-name of the customer
   /// @param customerPostalAddress-postal address of the seller
   /// @param customerEmail-email of the seller
    event customerRegistered(
        address customerAddress,
        string customerName,
        string customerPostalAddress,
        string customerEmail
    );
   /// @notice Emitted when a produce is added by the seller
   /// @param id-id of the produce added
   /// @param name-name of the produce
   /// @param price-price of the produce per kg.
   /// @param quantity-quanity added
   ///@param seller-public account key for the seller
    event ProduceAdded(
        uint256 id,
        string name,
        uint256 price,
        uint256 quantity,
        address seller
    );
    /// @notice Emitted when a produce is puchased by the customer
   /// @param id of the produce purchased
   /// @param name of the produce purchased
   /// @param price paid for the produce
   ///@param seller-public account key for the seller
   ///@param customer-public account key for the customer
    event ProductPurchased(
        uint256 id,
        string name,
        uint256 price,
        address seller,
        address customer
    );

    constructor() {}

    /// @notice Registers a seller by adding to the registeredSellers mapping
    /// @param _sellerName-Name of the Seller
    /// @param _postalAddress-postal address of the Seller
    /// @param _sellerEmail-Email of the seller
    /// @param sellerAddress-Public account key of the seller
    /// @dev Function can only be called by admin
    /// @dev Function grants seller role the seller public address
    function registerSeller(
        string memory _sellerName,
        string memory _postalAddress,
        string memory _sellerEmail,
        address sellerAddress
    ) external onlyAdmin {
        //check name is valid
        require(bytes(_sellerName).length > 0, "Name cannot be null");
        //check contact email is valid
        require(bytes(_sellerEmail).length > 0, "Contact email cannot be null");
        //Create a Seller
        sellerCount++;
        registeredSellers[sellerCount] = RegisteredSeller(
            sellerAddress,
            _sellerName,
            _postalAddress,
            _sellerEmail,
            0
        );
        //Grant seller role
        addSeller(sellerAddress);

        //Emit Event
        emit SellerRegistered(
            msg.sender,
            _sellerName,
            _postalAddress,
            _sellerEmail,
            0
        );
    }
    /// @notice Registers a customer by adding to the registeredCustomers mapping
    /// @param _customerName-Name of the Customer
    /// @param _postalAddress-postal address of the Customer
    /// @param _customerEmail-Email of the Customer
    /// @dev msg.sender is added as the customer
    /// @dev Function can be called by anyone
    /// @dev Function grants customer role the msg.sender address
    function registerCustomer(
        string memory _customerName,
        string memory _postalAddress,
        string memory _customerEmail
    ) external {
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
        //Create Customer
        customerCount++;
        registeredCustomers[customerCount] = RegisteredCustomers(
            msg.sender,
            _customerName,
            _postalAddress,
            _customerEmail
        );
        //Assign Customer Role
        addCustomer(msg.sender);

        //Emit Event
        emit customerRegistered(
            msg.sender,
            _customerName,
            _postalAddress,
            _customerEmail
        );
    }
    /// @notice Adds a produce by adding it to the produceList mapping
    /// @param _name-Name of the Produce
    /// @param _price-Price of the produce in Wei
    /// @param _quantity-Quantity available of the produce
    /// @dev Function can only be called by seller role
    function addProduce(
        string memory _name,
        uint256 _price,
        uint256 _quantity
    ) external onlySeller {
        //check if price is valid
        require(_price > 0, "Price cannot be 0");
        //check if quantity is valid
        require(_quantity > 0, "Price cannot be 0");

        //increment product counter
        produceCount++;
        //add product
        produceList[produceCount] = Produce(
            produceCount,
            _name,
            _price,
            _quantity,
            payable(msg.sender)
        );

        //emit event
        emit ProduceAdded(produceCount, _name, _price, _quantity, msg.sender);
    }
    /// @notice Purchases the produc by reducing the vaialble quantity in produceList and adding it to the CustomerOrders mapping
    /// @param _produceID-id of the produce
    /// @param _quantity-quantity to be purchased
    /// @dev Function can be called by customer role
    function purchaseProduce(uint256 _produceID, uint256 _quantity)
        external
        payable
        onlyCustomer
    {
        //check if msg.value is enough to buy produce
        require(msg.value >= produceList[_produceID].price * _quantity);
        //check if there is enough quanity to buy
        require(
            produceList[_produceID].quantity >= _quantity,
            "Not enough quantity"
        );
        //check if buyer is not the seller
        require(produceList[_produceID].seller != msg.sender);

        //add to the customerItems mappings
        orderCount++;
        customerOrders[orderCount] = customerOrder(
            produceList[_produceID].name,
            _quantity,
            produceList[_produceID].price * _quantity,
            msg.sender,
            produceList[_produceID].seller
        );

        //reduce the quantity available
        produceList[_produceID].quantity =
            produceList[_produceID].quantity -
            _quantity;

        //transfer ether to seller
        produceList[_produceID].seller.transfer(msg.value);

        //emit event
        emit ProductPurchased(
            _produceID,
            produceList[_produceID].name,
            produceList[_produceID].price,
            produceList[_produceID].seller,
            msg.sender
        );
    }
    /// @notice Gives rating to the seller
    /// @notice This fucntion is not currently being used
    /// @dev Function can only be called by customer role
    function giveSellerRating(
        address _sellerAddress,
        uint256 _rating,
        uint256 _produceID,
        uint256 _orderID
    ) external onlyCustomer returns (uint256) {
        //check if the address giving rating is not the seller
        require(
            produceList[_produceID].seller != msg.sender,
            "Seller cannot rate themselves"
        );
        //check if the customer has bought the product from the seller
        require(
            customerOrders[_orderID].seller == _sellerAddress,
            "Customer needs to buy the product before leaving review"
        );

        //check if rating is not greater than 5
        require(_rating <= 5, "Rating cannot be more than 5");

        //add rating
        registeredSellers[sellerCount].rating = _rating;

        //return rating
        return registeredSellers[sellerCount].rating;
    }
}
