# DiamondChain

A decentralized diamond authenticity verification system for tracking diamonds from mine to market on Stacks blockchain.

## Features

- Diamond registration with grade and certification tracking
- Miner stone management and provenance verification
- Gemology expert authentication system
- Extraction date and location tracking
- Comprehensive diamond authenticity monitoring

## Smart Contract Functions

### Public Functions
- `register-gemology-expert` - Register gemology expert (supervisor only)
- `register-diamond-stone` - Register new diamond stone
- `verify-diamond-authenticity` - Verify authenticity (expert only)

### Read-Only Functions
- `get-diamond` - Get diamond details
- `get-miner-stones` - Get miner's stone list
- `is-gemology-expert` - Check expert status
- `get-total-stones` - Get total registered stones
- `get-contract-stats` - Get contract statistics

## Usage

Deploy the contract to create a diamond authenticity system where miners can register their stones and gemology experts can verify authenticity throughout the supply chain.

## License

MIT