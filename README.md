# **Decentralized Membership Subscription Platform (Proxy Pattern) by Team 4 **

This project implements a decentralized membership subscription platform inspired by services like Twitch and Patreon, using Ethereum smart contracts. The platform allows creators to offer tiered subscription plans to their supporters and automates monthly payments using a trustless, blockchain-based system.

### **Key Features**

1. **Upgradeable Contract Architecture**:
   - The platform uses the **proxy pattern** to enable future upgrades of the subscription logic without disrupting user data or the contract's state. This ensures scalability and adaptability as the platform evolves.
2. **Tiered Subscription System**:

   - **Three Tiers**: Supporters can choose between 3 different membership tiers, each with a different monthly subscription cost (e.g., 10, 20, or 50 tokens).
   - **Automatic Monthly Payments**: Payments are made upfront, and each subsequent month, the contract attempts to charge the supporter. If they fail to have sufficient funds, they lose access to membership benefits until payment is restored.
   - **Loss of Benefits**: If the user doesn’t have enough funds in their wallet at the time of renewal, their membership and benefits will be suspended until they resubscribe.

3. **Tokenized Rewards**:

   - Supporters earn **reward points** (ERC20 tokens) for consuming the creator's content. These points can be redeemed or burned as part of the creator's content offering.

4. **Trustless Fee Distribution**:
   - The subscription payment is automatically split between the platform and the creator. A predefined **platform fee** is deducted, and the remainder is transferred to the creator, ensuring that the system operates **trustlessly** and without middlemen.
   - **Configurable Fees**: The platform fee and tier prices are adjustable by the platform admin.

### **Contracts Overview**

1. **Proxy Contract**:

   - Implements the proxy pattern for upgradeable contracts. Delegates calls to the logic contract, enabling future upgrades without affecting the current state of the contract.

2. **SubscriptionLogic Contract**:

   - Core subscription logic, handling user subscriptions, monthly payment processing, and tier management.
   - Implements fee splitting between the platform and creator.
   - Provides functions to renew subscriptions, cancel subscriptions, and check membership status.

3. **CreatorPoints (ERC20 Token)**:
   - An ERC20 token that represents **reward points** given to users for interacting with a creator's content. These tokens are minted by the platform or the creator and can be burned upon redemption.

### **Installation and Usage**

1. Install dependencies:

   ```bash
   npm install
   ```

2. Compile the contracts:

   ```bash
   npx hardhat compile
   ```

3. Deploy the contracts (you will need to configure `hardhat.config.js` for your network):

   ```bash
   npx hardhat run scripts/deploy.js --network <your-network>
   ```

### **Usage Guide**

1. **Proxy Pattern Setup**:

   - Deploy the **SubscriptionLogic** contract.
   - Deploy the **Proxy** contract, pointing to the logic contract.
   - Interact with the proxy to ensure upgradeability in the future.

2. **Subscription Management**:

   - Users can subscribe to one of the three available tiers.
   - The platform automatically processes monthly payments and suspends subscriptions if the user lacks sufficient funds.
   - Subscriptions can be renewed manually or automatically by the user.

3. **Reward Points System**:
   - Users earn reward tokens (ERC20) based on their engagement with the creator's content.
   - Tokens can be minted and burned by the creator or platform, based on user activity or rewards redemption.

### **Upgrading the Contract**

If the platform needs to upgrade its logic, deploy a new version of the **SubscriptionLogic** contract, and use the `upgradeImplementation()` function in the proxy contract to point to the new version, ensuring seamless upgrades.

### **Security Considerations**

- **Access Control**: Only the platform admin can modify platform fees or upgrade contract logic.
- **Balance Checks**: The platform ensures that users have sufficient balance for payments, and if they fail to meet payment requirements, their membership is suspended.
- **Upgradability**: Using the proxy pattern ensures the platform can evolve over time while maintaining user data integrity.

### **Future Enhancements**

- Support for additional tiers or dynamic tier pricing models.
- More advanced subscription management features (such as subscription pausing or one-time donations).
- Integration with content platforms to automate the reward points distribution based on user activity metrics.

### **Team Members id
- u9uZu4 
- XMeqxJ 
- h1oFbD 
- b3zZtF 
- dqf4RC 
- vTxFsv 

### **License**

This project is licensed under the MIT License. See the `LICENSE` file for details.
