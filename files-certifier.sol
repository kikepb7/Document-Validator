// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FilesCertifier {

    address public immutable owner;

    /// Estructura que representa un documento certificado
    struct Document {
        string url;
        bytes32 documentHash;
        address verifiedBy;
        bool valid;
    }

    /// Mapeo de hashes de documentos a su estructura de datos
    mapping(bytes32 => Document) public documents;

    /// Evento emitido cuando un documento es verificado correctamente
    event VerifiedDocument(string url, bytes32 hash, address verifiedBy);

    /// Constructor
    constructor() {
        owner = msg.sender;
    }

    /// @notice Verifica un documento mediante su URL y hash calculado off-chain
    /// @param _url URL del documento
    /// @param _userHash Hash calculado por el usuario (keccak256 de la URL)
    function verifyDocument(string memory _url, bytes32 _userHash) public {
        require(bytes(_url).length > 0, "URL vacia");
        require(_userHash != bytes32(0), "Hash invalido");
        require(!documents[_userHash].valid, "Documento ya verificado");

        // Generar hash interno a partir de la URL
        bytes32 generatedHash = keccak256(abi.encodePacked(_url));
        require(generatedHash == _userHash, "Hash no coincide con la URL");

        // Guardar documento verificado
        documents[_userHash] = Document({
            url: _url,
            documentHash: _userHash,
            verifiedBy: msg.sender,
            valid: true
        });

        emit VerifiedDocument(_url, _userHash, msg.sender);
    }

    /// @notice Consulta si un documento ha sido verificado
    /// @param _hash Hash del documento
    function isVerified(bytes32 _hash) public view returns (bool) {
        return documents[_hash].valid;
    }

    /// @notice Dona fondos al autor del documento verificado
    /// @param _hash Hash del documento al que se desea donar
    function donateAuthor(bytes32 _hash) public payable {
        require(documents[_hash].valid, "Documento no verificado");
        address author = documents[_hash].verifiedBy;
        require(author != address(0), "Autor no valido");

        payable(author).transfer(msg.value);
    }

    /// @notice Calcula el hash que el contrato espera para una URL
    /// @param _url URL del documento
    /// @return Hash keccak256 de la URL
    function calculateHash(string memory _url) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_url));
    }
}
