// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./intf/IUni.sol";
import "./lib/SafeMath.sol";
import "./intf/IERC20.sol";
import "./lib/Ownable.sol";
import "./lib/SafeERC20.sol";

contract ExchangeBroker is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IUni public uniswapRouter;
    address public _WETH_;

    fallback() external payable {
        require(msg.sender == _WETH_, "WE_SAVE_YOUR_TOKEN,FALLBACK");
    }

    receive() external payable {
        require(msg.sender == _WETH_, "WE_SAVE_YOUR_TOKEN,RECEIVE");
    }

    event Swap(
        address indexed account,
        address[] indexed path,
        uint256 amountIn,
        uint256 amountOut
    );

    constructor(address payable _weth, address payable _uni) public Ownable() {
        uniswapRouter = IUni(_uni);
        _WETH_ = _weth;
    }

    function swapProxy(uint256 amountIn, address[] calldata path) external {
        uint256 balance = IERC20(path[0]).balanceOf(msg.sender);
        require(balance >= amountIn, "not sufficient balance");

        IERC20(path[0]).approve(address(uniswapRouter), amountIn);
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);

        uint256[] memory amounts = uniswapRouter.swapExactTokensForTokens(
            amountIn,
            uint256(0),
            path,
            address(this),
            block.timestamp + 300
        );

        uint256 toOut = amounts[amounts.length - 1].mul(uint256(9200)).div(
            uint256(10000)
        );
        IERC20(path[path.length - 1]).safeApprove(address(this), 0);
        IERC20(path[path.length - 1]).safeApprove(address(this), toOut);
        IERC20(path[path.length - 1]).safeTransfer(msg.sender, toOut);
        emit Swap(msg.sender, path, amountIn, toOut);
    }

    function getAmountOut(uint256 amountIn, address[] memory path)
        private
        returns (uint256[] memory)
    {
        return uniswapRouter.getAmountsOut(amountIn, path);
    }

    function claimFee(address token) external payable onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (token == address(_WETH_)) {
            msg.sender.transfer(balance);
        } else {
            IERC20(token).safeTransfer(msg.sender, balance);
        }
    }
}
