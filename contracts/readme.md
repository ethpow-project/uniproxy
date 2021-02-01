
```bash
MNEMONIC="talent flee diamond body razor possible uniform give hat survey live nothing" INFURA_API_KEY="c844845b06f84d379ba3fb3bba5a1f99" truffle deploy --network=kovan  --reset
```


### UNISWAP ROUTER 地址： 

UniswapV2Router01.sol
0xf164fC0Ec4E93095b804a4795bBe1e041497b92a


UniswapV2Router02.sol
0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D


function wrap() public payable restricted {
    if (msg.value != 0) {
      WETH.deposit{value : msg.value}();
      WETH.transfer(address(this), msg.value);
    }
}

function unwrap(uint amount) public payable restricted {
    if (amount != 0) {
        WETH.withdraw(amount);
        msg.sender.transfer(address(this).balance);
    }
}




