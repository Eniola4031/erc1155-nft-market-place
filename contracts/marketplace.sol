
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


abstract contract MarketPlace is ERC1155Holder,IERC1155{

    struct SellOrder{
        ERC1155 token;
        IERC20 erc20;
        uint256 tokenAmount;
        uint256 weiAmount;
        uint256 timeListed;
        uint256 deadline;
        uint256 tokenCount;
        uint256 id;
        address owner;
        bool fulfilled;
        bool weiList;
        bool available;
    }
    mapping(uint=>SellOrder) allOrders;

    uint256 orderCounter = 0;
    IERC20 staToken;

    constructor(IERC20 _token){
        stToken = _token;

    }
    modifier onlySaleLister(uint256 _orderId){
        require(msg.sender==allOrders[_orderId].owner,"You are not the order owner");
        _;
    }
modifier onlyAvailable(uint256 _orderId){
require(allOrders[_orderId].available, "order not available for sale");
}
    function setSaleOrder(
        address _token,
        uint256 _tokenId,
        bool _weiList, 
        uint256 _weiPrice, 
        uint256 _tokenCount, 
        uint256 _token){
        require(IERC1155(_TOKEN.balanceOf(msg.sender, _tokenId)>=_tokenCount, "You do not have that much tokens to sell");
        IERC1155(_token).setApprovalForAll(address(this),true);
        SellOrder storage s = allOrders[orderCounter];
s.token = IERC1155(_token);
s.timeListed = block.timestamp;
s.deadline = block.timestamp + (days *1 days);
s.tokenCount = _tokenCount;
s.id = _tokenId;
s.owner = msg.sender;
if(_weiList){
    require(_tokenPrice == 0,"Token price should be 0");
    require(_weiPrice>0,"wei price should be greater than 0");
    s.weiAmount = _weiPrice;
}
if(!_weilist){
    require(_weiPrice = 0,"Wei Price should be 0");
    require(_tokenPrice >0, "Token price should be greater than 0");
    s.tokenAmount= _tokenPrice;
}
s.available= true;
orderCounter++;
//orderCounter.increment();
    }
    function fulfillOrder(uint256 _orderId) external payable{
        SellOrder storage s =allOrders[_orderId];
        require(!s.fulfiled, "Order has been fulfilled");
        require(s.token.isApprovedForAll(s.owner, address(this)),"should approve this contract as the operator first");
        require(s.token.balanceOf(s.owner, s.id)>=s.tokenCount,"owner should never be greater than or equal tokens");
    if(s._weiList){
        payable(s.owner).transfer(s.weiAmount);
    }
    if(!s._weiList){
        require(stToken.allowance(msg.sender, address(this))>=s.tokenAmount, "you have to approve the token first");
        require(stToken.transferFrom(msg.sender, s.owner, s.tokenAmount));
        s.token.safeTransferFrom(s.owner, msg.sender, s.id, s.tokenCount,"");
    }
    s.fulfilled= true;
    s.available= false;
    }

    function checkOrder(uint256 _orderId)public view returns(SellOrder memory){
 return allOrders[_orderId];
    }
    fucntion changeOrderPrice(
        uint256 _orderId,
        uint256 _newwiePrice, 
        uint256 _newTokenPrice)
        public onlySaleLister(_orderId){
require(!allOrders[_orderId].fulfilled, "Order already fulfilled");
if(allOrders[_orderId].weiList){
    allOrders[_orderId].weiAmount= _newwiePrice;
}
if (!allOrders[_orderId]weiList){
    allOrder[_orderId].tokenAmount = _newTokenPrice;
}
    }
    function cancelOrder(uint256 _orderId) public onlySaleLister(_orderId){
        allOrders[_orderId].available=false;
    }
}



