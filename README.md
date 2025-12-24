# 🟣 **Private P2P Loan Limit — ZAMA FHEVM**

### Fully Homomorphic Encrypted P2P Loan Eligibility on Ethereum

This project demonstrates a **privacy‑preserving P2P loan eligibility system** built on **Zama’s FHEVM (Fully
Homomorphic Encryption Virtual Machine)**.

Borrowers submit their **income encrypted in the browser**, and the smart contract evaluates loan eligibility **without
ever revealing the income on‑chain**. The minimum income threshold is also stored **fully encrypted** and controlled by
an admin.

The result (approved / rejected) can be **publicly decrypted**, while the user’s income remains **private and only
decryptable by the user**.

---

## ✨ Features

### 🔒 1. Fully Encrypted User Inputs

Users submit:

- `income` (`uint64` → encrypted `euint64`)

Encryption happens client‑side using **Zama Relayer SDK** before any transaction is sent.

---

### 🧠 2. Private On‑Chain Computation

The smart contract evaluates the condition:

```
income >= minIncome
```

This comparison is executed **homomorphically** inside the FHEVM. The contract never sees plaintext values.

---

### 🔐 3. Dual Decryption Model

- ✅ **Public decrypt** — loan decision (`approved / rejected`)
- 🔑 **User decrypt** — user’s own encrypted income (via EIP‑712 + ephemeral keys)

This enables transparency for decisions while preserving personal privacy.

---

### 🛡 4. Encrypted Admin Policy

The admin sets:

```
minIncome : euint64
```

- Stored encrypted on‑chain
- Publicly decryptable (for transparency)
- Modifiable only by the contract owner

---

### 🖥 5. Interactive Frontend

Pure **HTML + JavaScript** frontend with:

- Wallet connection (ethers v6)
- Public or user encryption toggle
- Encrypted submission flow
- Public / user decryption
- Admin policy panel
- **ZAMA‑branded console logger** 🟣

---

## 📦 Project Structure

```
├── contracts/
│   └── PrivateP2PLoanLimit.sol
├── frontend/
│   └── index.html
├── scripts/
│   └── deploy.ts
├── hardhat.config.ts
├── package.json
├── server.js
└── README.md
```

---

## 🔧 Smart Contract Overview

### Contract: `PrivateP2PLoanLimit`

Key encrypted state:

```
euint64 eMinIncome
mapping(address => Application)
```

```
struct Application {
  euint64 eIncome;
  ebool   eApproved;
  bool    decided;
}
```

---

### `setMinIncome(externalEuint64, proof)` — **Owner only**

Sets encrypted minimum income threshold.

Flow:

1. Import encrypted value using `FHE.fromExternal`
2. Grant contract access
3. Make value publicly decryptable
4. Emit handle event

---

### `submitIncome(externalEuint64, proof)`

User submits encrypted income (public or user encrypted).

Contract:

1. Imports encrypted income
2. Grants user + contract access
3. Computes:

```
approved = income >= minIncome
```

4. Stores encrypted income + decision
5. Makes decision publicly decryptable
6. Emits decision handle

---

### View Functions (Handles Only)

- `getDecisionHandle(address)` → encrypted approval decision
- `getMyIncomeHandle()` → encrypted user income
- `hasSubmitted(address)` → UX helper

⚠️ No plaintext data is ever returned.

---

## 🔐 Homomorphic Logic

### Approval Condition

```
FHE.ge(eIncome, eMinIncome)
```

Result stored as encrypted `ebool`.

---

## 🌐 Frontend Overview

### ✔ Wallet Connection

Uses **ethers.js v6 BrowserProvider**.

---

### ✔ Encryption Flow

```
const enc = relayer.createEncryptedInput(contract, user)
enc.add64(income)
enc.encrypt({ user: true | false })
```

Supports:

- Public encryption
- User encryption

---

### ✔ Decryption Flow

#### Public decrypt

```
relayer.publicDecrypt([handle])
```

#### User decrypt

- Ephemeral keypair
- EIP‑712 signed request
- `relayer.userDecrypt(...)`

---

### ✔ Admin Flow

- Owner check via `owner()`
- Encrypt new `minIncome`
- Call `setMinIncome`

---

## 🟣 ZAMA Branded Logger

The frontend includes a custom ZAMA logger with structured logs:

- `EVENT` — user actions
- `STEP` — encryption / signing steps
- `TX` — blockchain calls
- `SUCCESS / ERROR`
- `BLOCK` — object inspection

Example output:

```
[ZAMA] Submit income
🔧 STEP Encrypting income
🔐 ENCRYPTED HANDLES [0xabc...]
📡 TX Calling submitIncome()
✔ SUCCESS submitIncome confirmed
```

---

## 🔄 Data Flow Diagram

```
User Browser
   │
   │ encrypt(income)
   ▼
Zama Relayer SDK
   │
   │ ciphertext + ZK proof
   ▼
FHEVM Smart Contract
   │
   │ homomorphic comparison
   ▼
Encrypted decision (ebool)
   │
   ├─ publicDecrypt()
   └─ userDecrypt()
```

---

## 🚀 Deployment

### 1. Install dependencies

```bash
npm install
```

### 2. Deploy contract

```bash
npx hardhat run scripts/deploy.ts --network sepolia
```

### 3. Update frontend

```js
const CONTRACT = "0xYourDeployedAddress";
```

---

## 🖥 Running the Frontend

Inside of the project root, run:

```bash
npm run start
```

## Open http://localhost:3001 in your browser.

---

## 🛡 Security Guarantees

✔ Client‑side encryption only ✔ No plaintext stored on‑chain ✔ Encrypted admin policy ✔ User‑only decryptable
private data ✔ Public transparency for decisions ✔ Reentrancy guard ✔ Owner‑protected admin actions

---

## 📄 License

MIT — compatible with Zama reference contracts.

---

## 🤝 Credits

Built with ❤️ using:

- **Zama FHEVM**
- **Zama Relayer SDK**
- **Ethers.js v6**
- **Sepolia Testnet**

---
