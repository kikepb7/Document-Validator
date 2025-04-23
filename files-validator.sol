// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
    hashFile de prueba: 0x5f16f774c97cb8b32b2c02884d3fc7c41abf9a1b7b7f3c4f2f9cbd50a0be6ec7
*/
contract FilesValidator {

    address public firstAccount;    // Despliega el contrato
    address public secondAccount;   // La otra parte firmante
    uint public amount;
    bytes32 public hashFile;        // Hash del archivo a firmar
    bool public firstAccountConfirmation;
    bool public secondAccountConfirmation;

    constructor(address _secondAccount, uint _amount, bytes32 _hashFile) {
        firstAccount = msg.sender;
        secondAccount = _secondAccount;
        amount = _amount;
        hashFile = _hashFile;
    }

    // Payable function --> únicamente puede ser llamada por firstAccount y verifica que la cantidad enviada sea igual que 'amount'
    function amountDeposit() external payable {
        require(msg.sender == firstAccount, "Solo la cuenta del primer cliente puede hacer el deposito");
        require(msg.value == amount, "El  valor enviado por el primer cliente no es correcto");
    }

    // Esta función marca la confirmación como verdadera
    function confirmFile() external {
        if (msg.sender == firstAccount) {
            firstAccountConfirmation = true;
        } else if (msg.sender == secondAccount) {
            secondAccountConfirmation = true;
        }else{
            revert("Solo la cuenta del primer cliente puede confirmar el archivo");
        }

        // Si ambas partes han confirmado y hay fondos en el contrato, se transfiere automáticamente el dinero a la secondAccount
        if (firstAccountConfirmation && secondAccountConfirmation && address(this).balance >= amount) {
            transferAmount();
        }
    }

    // Transferir la cantidad a secondAccount si las dos partes validan el documento
    function transferAmount() private {
        payable(secondAccount).transfer(address(this).balance);
    }

    // Consultar el saldo (ETH) del contrato
    function checkAmountContract() public view returns (uint) {
        return address(this).balance;
    }

    // Verifica si el documento fue validado completamente
    function isValidated() public view returns (bool) {
        return firstAccountConfirmation && secondAccountConfirmation;
    }
}