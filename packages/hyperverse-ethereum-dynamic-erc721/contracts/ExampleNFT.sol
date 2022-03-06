// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import './MDynamicERC721.sol';

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ExampleNFT is MDynamicERC721 {
	uint256 public tokenCounter;

	// Account used to deploy contract
	address public immutable contractOwner;

	//stores the tenant owner
	address private tenantOwner;

	// Have to put ERC721 here to truly inherit this contract
	// _safeMint only available `internal`ly which is
	// only possible if we call the constructor like this
	constructor() {
		contractOwner = msg.sender;
	}

	function init(
		string memory name_,
		string memory symbol_,
		address _tenant,
		string[] memory _globalMetadataKeys,
		string[] memory _globalMetadata,
		NumericalProperty[] memory _numericalProperties,
		StringProperty[] memory _stringProperties
	) external {
		merc721Init(name_, symbol_);
		dynamicMetadataInit(
			_globalMetadataKeys,
			_globalMetadata,
			_numericalProperties,
			_stringProperties
		);
		tenantOwner = _tenant;
		tokenCounter = 0;
	}

	function createNFT(
		address to,
		string[] memory _stringValues,
		uint256[] memory _numValues
	) public returns (uint256) {
		require(msg.sender == tenantOwner, 'Only the Tenant owner can mint an NFT');
		require(
			_numValues.length == numberIndex && _stringValues.length == stringIndex,
			'Number of values must match the number of properties'
		);
		uint256 newNFTTokenId = tokenCounter;
		//safely mint token for the person that called the function
		_safeMint(to, newNFTTokenId);
		//set the metadata
		MetadataFields storage fields = metadataFields[newNFTTokenId];
		mapping(uint256 => string) storage stringValues = fields.stringProperties;
		mapping(uint256 => uint256) storage numValues = fields.numericalProperties;
		for (uint256 i = 0; i < stringIndex; i++) {
			stringValues[i] = _stringValues[i];
		}
		for (uint256 i = 0; i < numberIndex; i++) {
			numValues[i] = _numValues[i];
		}
		//increment the counter
		tokenCounter = tokenCounter + 1;
		//return the token id
		return newNFTTokenId;
	}

	function addNumericalProp(string memory _propertyName, bool _isEditable) public {
		require(msg.sender == tenantOwner, 'Only the Tenant owner can add a numerical property');
		addNumericalProperty(_propertyName, _isEditable);
	}

	function editNumericalProp(
		uint256 _propId,
		string memory _key,
		bool _isEditable
	) public {
		require(msg.sender == tenantOwner, 'Only the Tenant owner can edit a numerical property');
		editNumericalProperty(_propId, _key, _isEditable);
	}

	function setNumericalValue(
		uint256 _tokenId,
		uint256 _propertyId,
		uint256 _value
	) public onlyTokenOwner(_tokenId) {
		require(numericalProperties[_propertyId].editable, 'Property is not editable');
		metadataFields[_tokenId].numericalProperties[_propertyId] = _value;
	}

	function addStringProp(string memory _propertyName, bool _isEditable) public {
		require(msg.sender == tenantOwner, 'Only the Tenant owner can add a string property');
		addStringProperty(_propertyName, _isEditable);
	}

	function editStringProp(
		uint256 _propId,
		string memory _key,
		bool _isEditable
	) public {
		require(msg.sender == tenantOwner, 'Only the Tenant owner can edit a string property');
		editStringProperty(_propId, _key, _isEditable);
	}

	function setStringValue(
		uint256 _tokenId,
		uint256 _propertyId,
		string memory _value
	) public onlyTokenOwner(_tokenId) {
		require(stringProperties[_propertyId].editable, 'Property is not editable');
		metadataFields[_tokenId].stringProperties[_propertyId] = _value;
	}

	function addGlobalProp(string memory _propertyName, string memory _propertyValue) public {
		require(msg.sender == tenantOwner, 'Only the Tenant owner can add a global property');
		addGlobalMetadata(_propertyName, _propertyValue);
	}

	function editGlobalProp(
		uint256 _propIndex,
		string memory _propertyName,
		string memory _propertyValue
	) public {
		require(msg.sender == tenantOwner, 'Only the Tenant owner can edit a global property');
		editGlobalMetadata(_propIndex, _propertyName, _propertyValue);
	}

	modifier onlyTokenOwner(uint256 _tokenId) {
		require(ownerOf(_tokenId) == msg.sender, 'Only the token owner can do this');
		_;
	}
}
