import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const BankModule = buildModule("BankModule", (m) => {
  const bank = m.contract("Bank");

  return { bank };
});

export default BankModule;
