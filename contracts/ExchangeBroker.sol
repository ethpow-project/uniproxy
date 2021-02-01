
// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./intf/IUni.sol";
import "./lib/SafeMath.sol";
import "./intf/IERC20.sol";
import "./lib/Ownable.sol";
import "./lib/SafeERC20.sol";

// 合约调用Uniswap进行交易
// 用户的币 打到 我们合约，我们返回用户
// need user approve 
contract ExchangeBroker is Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    //weth 
    // kovan weth 0xd0a1e359811322d97991e03f863a0c30c2cf029c
    // mainnet weth 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
    address public _WETH_ = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;

    //UNI ROUTER 02
    address public _UNI_ = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    fallback() external payable {
        require(msg.sender == _WETH_, "WE_SAVE_YOUR_TOKEN,FALLBACK");
    }

    receive() external payable {
        require(msg.sender == _WETH_, "WE_SAVE_YOUR_TOKEN,RECEIVE");
    }

    function price(address tokenIn,address tokenOut,uint256 amountIn) external view returns(uint256){
       address[] memory path = new address[](3);
       path[0] = tokenIn;
       path[1] = _WETH_;
       path[2] = tokenOut;
       uint[] memory amounts = IUni(_UNI_).getAmountsOut(amountIn,path);
       return amounts[1];
    }

    //ETH , WETH , WBTC   / USDT 
    function swapProxy(address token, address tokenb, uint256 value) public payable {

        uint256 balance = IERC20(token).balanceOf(msg.sender);
        require(balance >= value, "not sufficient balance");

        IERC20(token).transferFrom(msg.sender, address(this), value);
        
        uint256 _balance = IERC20(token).balanceOf(address(this));
        if (_balance >= value) {
            //do save approve
            IERC20(token).safeApprove(_UNI_, uint256(0));
            IERC20(token).safeApprove(_UNI_, value);
            //require(false, "err2");
            address[] memory path = new address[](3);
            //set is not eth  
            path[0] = token;
            path[1] = _WETH_;
            path[2] = tokenb;

            uint256[] memory amounts = IUni(_UNI_).swapExactTokensForTokens(value, uint256(0), path, address(this), now.add(1800));
            
            if (amounts[0] > uint256(0)) {
                //balancer 扣取 3/1000 
                // _balance = amounts[0].mul(uint256(997)).div(uint256(1000));
                IERC20(tokenb).transfer(msg.sender, amounts[0]);
            }
        }
        
    }

    //提取币到
    function claimFee(address token) external payable onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (token == address(_WETH_)) {
            //IERC20(_WETH_).withdraw(balance);
            msg.sender.transfer(balance);
        } else {
            IERC20(token).transfer(msg.sender, balance);
        }
    }

}
