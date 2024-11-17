// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Swapping.sol";
import "v3-periphery/interfaces/ISwapRouter.sol";

contract SwappingTest is Test {
    SingleSwap public swapper;
    
    address constant ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address constant TOKEN1 = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F; // USDT
    address constant TOKEN2 = 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6; // WBTC
    
    address public user = makeAddr("user");
    
    function setUp() public {
        // Fork mainnet
        vm.createSelectFork("https://polygon-mainnet.g.alchemy.com/v2/miIScEoe9D6YBuuUrayW6tN7oecsWApe");        
        // Deploy the contract with 0.05% fee tier
        swapper = new SingleSwap(
            ROUTER,
            TOKEN1,
            TOKEN2,
            500  // Try 500 (0.05%) fee tier first
        );
        
        // Deal USDT directly to the swapper contract
        deal(TOKEN1, address(swapper), 1000 * 1e6);
    }

    function test_swap() public {
        // Get initial balances
        uint256 initialUsdtBalance = IERC20(TOKEN1).balanceOf(address(swapper));
        uint256 initialWbtcBalance = IERC20(TOKEN2).balanceOf(address(swapper));
        
        console.log("Initial USDT balance of swapper:", initialUsdtBalance, "USDT");
        console.log("Initial WBTC balance of swapper:", initialWbtcBalance , "WBTC");
        
        // Calculate minimum amount out (0.0011 BTC = 110000 satoshis)
        uint256 minAmountOut = 110000; // 0.0011 BTC in satoshis
        
        vm.prank(user);
        // Perform swap (swap 1000 USDT)
        uint256 amountOut = swapper.swapExactInputSingle(1000 * 1e6, minAmountOut);
        
        // Check final balances
        uint256 finalUsdtBalance = IERC20(TOKEN1).balanceOf(address(swapper));
        uint256 finalWbtcBalance = IERC20(TOKEN2).balanceOf(address(swapper));
        
        console.log("Final USDT balance of swapper:", finalUsdtBalance , "USDT");
        console.log("Final WBTC balance of swapper:", finalWbtcBalance , "WBTC");
        console.log("Amount of WBTC received:", amountOut , "WBTC");
        
        // Assertions
        assertEq(finalUsdtBalance, initialUsdtBalance - (1000 * 1e6), "USDT balance should decrease by 1000");
        assertGt(finalWbtcBalance, initialWbtcBalance, "Swapper should receive WBTC");
        assertGe(amountOut, minAmountOut, "Should receive at least 0.0011 WBTC");
    }
}
