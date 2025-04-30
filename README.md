# Kolective Smart Contract

This project deploys a set of mock tokens, a token factory, and a core smart contract for handling token swaps and liquidity, using Foundry.

## Prerequisites

Ensure you have Foundry installed. If not, install it using:
```sh
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Environment Variables
Create a `.env` file and add the following variables:
```sh
SONIC_API_KEY=
SONIC_TESTNET_RPC=
ETHERSCAN_API_KEY=
PRIVATE_KEY=
```

## Installation
Clone the repository and install dependencies:
```sh
git clone https://github.com/Kolective/kolective-sc
cd kolective-sc
forge install
```

## Contracts Overview

### **1. Deploy Script (`Deploy.sol`)**
- Deploys `TokenFactory` for creating ERC-20 tokens.
- Deploys `Core` contract for handling liquidity and swaps.
- Creates multiple tokens (SONIC, ETH, BTC, etc.) with predefined prices and liquidity.
- Adds liquidity to the `Core` contract.

### **2. Core Contract (`Core.sol`)**
- Manages liquidity and token prices.
- Allows adding and removing liquidity.
- Implements a swap function with a 0.3% fee.
- Emits events for liquidity changes and swaps.

### **3. MockToken Contract (`MockToken.sol`)**
- ERC-20 token implementation.
- Allows minting and price setting.
- Used for testing token deployment and swaps.

### **4. TokenFactory Contract (`TokenFactory.sol`)**
- Factory contract for creating new ERC-20 tokens.
- Allows users to deploy custom tokens with specified parameters.

## Deployment
To deploy the contracts, use:
```sh
forge script script/Deploy.s.sol:Deploy \
  --rpc-url https://rpc.blaze.soniclabs.com \
  --private-key $PRIVATE_KEY \
  --broadcast --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --verifier blockscout \
  --verifier-url https://api-testnet.sonicscan.org/api \
  --via-ir
```

## Testing
Run tests using:
```sh
forge test
```

## Improvements & Security Considerations
- Restrict `setPriceAndLiquidity` to only the contract owner.
- Improve swap fee calculations for accuracy.
- Optimize storage by using `uint128` instead of `uint256` for token prices.

## License
This project is licensed under the MIT License.