// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HumanID {

    address public owner;

    struct PersonalData {
        string fullname;
        uint256 date_of_birth;
        string email;
        string phone;
    }

    struct PassportData {
        string id_number;
        string nationality;
        uint256 date_of_issue;
        uint256 date_of_expiry;
    }


    struct Human {
        PersonalData personal_data;
        PassportData passport_data;
        address public_key;
        bytes32 private_key;
    }

    mapping (address => Human) public humans;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    function addHuman(string memory _fullname, uint256 _date_of_birth, string memory _id_number, string memory _nationality, uint256 _date_of_issue, uint256 _date_of_expiry, string memory _email, string memory _phone, string memory _password, string[7] memory _secret_phrases) public onlyOwner returns (address, bytes32) {

        // Generate public key from phone number and email
        address public_key = generatePublicKey(_phone, _email);

        // Generate private key from password and secret phrases
        bytes32 private_key = generatePrivateKey(_password, _secret_phrases);

        PersonalData memory personal_data = getPersonalData(_fullname, _date_of_birth, _email, _phone);

        PassportData memory passport_data = getPassportData(_id_number, _nationality, _date_of_issue, _date_of_expiry);


        Human memory new_human = Human({
            personal_data: personal_data,
            passport_data: passport_data,
            public_key: public_key,
            private_key: private_key
        });

        // Add new record to the mapping
        humans[public_key] = new_human;

        return (public_key, private_key);
    }

    function getPersonalData(string memory _fullname, uint256 _date_of_birth, string memory _email, string memory _phone) private pure returns (PersonalData memory) {
        return PersonalData({
            fullname: _fullname,
            date_of_birth: _date_of_birth,
            email: _email,
            phone: _phone
        });
    }

    function getPassportData(string memory _id_number, string memory _nationality, uint256 _date_of_issue, uint256 _date_of_expiry) private pure returns (PassportData memory) {
        return PassportData({
            id_number: _id_number,
            nationality: _nationality,
            date_of_issue: _date_of_issue,
            date_of_expiry: _date_of_expiry
        });
    }


    function generatePublicKey(string memory _phone, string memory _email) private pure returns (address) {
        // Generate public key from phone number and email
        return address(uint160(uint256(keccak256(abi.encodePacked(_phone, _email)))));
    }

    function generatePrivateKey(string memory _password, string[7] memory _secret_phrases) private pure returns (bytes32) {
        // Concatenate the secret phrases into a single string
        string memory concatenated_secret_phrases = string(abi.encodePacked(_secret_phrases[0], _secret_phrases[1], _secret_phrases[2], _secret_phrases[3], _secret_phrases[4], _secret_phrases[5], _secret_phrases[6]));

        // Generate private key from password and secret phrases
        return keccak256(abi.encodePacked(_password, concatenated_secret_phrases));
    }

    function recoverPublicKey(string memory _email, string memory _phone) public view returns (address) {
        // Generate public key from phone number and email
        address public_key = generatePublicKey(_phone, _email);

        // Check if the public key exists in the mapping
        require(humans[public_key].public_key == public_key, "No record found for the given email and phone number");

        return public_key;
    }

    function recoverPrivateKey(string memory _password, string[7] memory _secret_phrases) public view returns (bytes32) {
        // Concatenate the secret phrases into a single string
        string memory concatenated_secret_phrases = string(abi.encodePacked(_secret_phrases[0], _secret_phrases[1], _secret_phrases[2], _secret_phrases[3], _secret_phrases[4], _secret_phrases[5], _secret_phrases[6]));

        // Generate private key from password and secret phrases
        bytes32 private_key = keccak256(abi.encodePacked(_password, concatenated_secret_phrases));

        // Check if the private key exists in the mapping
        require(humans[msg.sender].private_key == private_key, "Incorrect password or secret phrases");

        return private_key;
    }
}

