// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DynamicMetadata {
	string[] public globalMetadata; // Properties that every NFT has
	string[] public globalMetadataKeys; // Properties that every NFT has
	mapping(uint256 => StringProperty) public stringProperties; // String values
	uint256 public stringIndex; // Current index of created string properties
	mapping(uint256 => NumericalProperty) public numericalProperties; // Numerical values
	uint256 public numberIndex; // Current index of created numerical properties
	mapping(uint256 => MetadataFields) metadataFields; // Token ID to metadata fields mapping

	function dynamicMetadataInit(
		string[] memory _globalMetadataKeys,
		string[] memory _globalMetadata,
		NumericalProperty[] memory _numericalProperties,
		StringProperty[] memory _stringProperties
	) internal {
		require(_globalMetadata.length == _globalMetadataKeys.length, 'Invalid structure');
		for (uint256 i = 0; i < _globalMetadata.length; i++) {
			globalMetadata.push(_globalMetadata[i]);
		}
		for (uint256 i = 0; i < _numericalProperties.length; i++) {
			numericalProperties[i] = NumericalProperty(
				_numericalProperties[i].propertyName,
				_numericalProperties[i].editable
			);
			numberIndex++;
		}
		for (uint256 i = 0; i < _stringProperties.length; i++) {
			stringProperties[i] = StringProperty(
				_stringProperties[i].propertyName,
				_stringProperties[i].editable
			);
			stringIndex++;
		}
	}

	function buildTokenURI(uint256 _tokenId) public view returns (string memory) {
		string memory metadata = '{\n';
		MetadataFields storage fields = metadataFields[_tokenId];
		// Loop through global metadata
		for (uint256 index = 0; index < globalMetadata.length; index++) {
			// Open metadata field key
			metadata = string(abi.encodePacked(metadata, '"'));
			metadata = string(abi.encodePacked(metadata, globalMetadataKeys[index]));
			// Close metadata field key
			metadata = string(abi.encodePacked(metadata, '": '));
			// Open metadata field value
			metadata = string(abi.encodePacked(metadata, '"'));
			metadata = string(abi.encodePacked(metadata, string(globalMetadata[index])));
			// Close metadata field value
			metadata = string(abi.encodePacked(metadata, '"'));
			if (index != globalMetadata.length - 1) {
				metadata = string(abi.encodePacked(metadata, ',\n'));
			}
		}
		// Check if there's a comma to add
		if (globalMetadata.length > 0 && (numberIndex > 0 || stringIndex > 0)) {
			metadata = string(abi.encodePacked(metadata, ',\n'));
		}

		// Loop through string properties
		for (uint256 index = 0; index < stringIndex; index++) {
			// Open metadata field key
			metadata = string(abi.encodePacked(metadata, '"'));
			metadata = string(abi.encodePacked(metadata, stringProperties[index].propertyName));
			// Close metadata field key
			metadata = string(abi.encodePacked(metadata, '": '));
			// Open metadata field value
			metadata = string(abi.encodePacked(metadata, '"'));
			metadata = string(abi.encodePacked(metadata, string(fields.stringProperties[index])));
			// Close metadata field value
			metadata = string(abi.encodePacked(metadata, '"'));
			if (index != stringIndex - 1) {
				metadata = string(abi.encodePacked(metadata, ',\n'));
			}
		}
		// Check if there's a comma to add
		if (stringIndex > 0 && numberIndex > 0) {
			metadata = string(abi.encodePacked(metadata, ',\n'));
		}

		// Loop through numerical properties
		for (uint256 index = 0; index < numberIndex; index++) {
			// Open metadata field key
			metadata = string(abi.encodePacked(metadata, '"'));
			metadata = string(abi.encodePacked(metadata, numericalProperties[index].propertyName));
			// Close metadata field key
			metadata = string(abi.encodePacked(metadata, '": '));
			// Open metadata field value
			metadata = string(abi.encodePacked(metadata, '"'));
			metadata = string(
				abi.encodePacked(metadata, uint2str(fields.numericalProperties[index]))
			);
			// Close metadata field value
			metadata = string(abi.encodePacked(metadata, '"'));
			if (index != numberIndex - 1) {
				metadata = string(abi.encodePacked(metadata, ',\n'));
			}
		}
		// Close metadata
		metadata = string(abi.encodePacked(metadata, '\n}'));
		return metadata;
	}

	function getStringProperty(uint256 _tokenId, uint256 _strIndex)
		public
		view
		returns (string memory)
	{
		return metadataFields[_tokenId].stringProperties[_strIndex];
	}

	function getNumericalProperty(uint256 _tokenId, uint256 _numIndex)
		public
		view
		returns (uint256)
	{
		return metadataFields[_tokenId].numericalProperties[_numIndex];
	}

	function addNumericalProperty(string memory _name, bool _editable) internal {
		numericalProperties[numberIndex] = NumericalProperty(_name, _editable);
		numberIndex++;
	}

	function editNumericalProperty(
		uint256 _propIndex,
		string memory _key,
		bool _isEditable
	) internal {
		numericalProperties[_propIndex] = NumericalProperty(_key, _isEditable);
	}

	function addStringProperty(string memory _name, bool _editable) internal {
		stringProperties[stringIndex] = StringProperty(_name, _editable);
		stringIndex++;
	}

	function editStringProperty(
		uint256 _propIndex,
		string memory _key,
		bool _isEditable
	) internal {
		stringProperties[_propIndex] = StringProperty(_key, _isEditable);
	}

	function addGlobalMetadata(string memory _key, string memory _value) internal {
		globalMetadataKeys.push(_key);
		globalMetadata.push(_value);
	}

	function editGlobalMetadata(
		uint256 _index,
		string memory _key,
		string memory _value
	) internal {
		globalMetadataKeys[_index] = _key;
		globalMetadata[_index] = _value;
	}

	function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
		if (_i == 0) {
			return '0';
		}
		uint256 j = _i;
		uint256 len;
		while (j != 0) {
			len++;
			j /= 10;
		}
		bytes memory bstr = new bytes(len);
		uint256 k = len;
		while (_i != 0) {
			k = k - 1;
			uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
			bytes1 b1 = bytes1(temp);
			bstr[k] = b1;
			_i /= 10;
		}
		return string(bstr);
	}
}

struct MetadataFields {
	mapping(uint256 => string) stringProperties;
	mapping(uint256 => uint256) numericalProperties;
}

struct NumericalProperty {
	string propertyName;
	bool editable;
}

struct StringProperty {
	string propertyName;
	bool editable;
}
