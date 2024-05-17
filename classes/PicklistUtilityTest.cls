@IsTest
private class PicklistUtilityTest {

	@IsTest
	static void testBaseCombobox() {
		Test.startTest();
		PicklistUtility.ComboboxValue combobox = new PicklistUtility.ComboboxValue( 'value', 'label' );
		Test.stopTest();

		System.assertEquals( combobox.value, 'value', 'ComboboxValue value property value should match the parameter' );
		System.assertEquals( combobox.label, 'label', 'ComboboxValue label property value should match the parameter' );
	}

	@IsTest
	static void testPicklistCombobox() {

		Test.startTest();

		List<Schema.PicklistEntry> picklistEntries = SchemaService.getPicklistValues( 'User', 'EmailEncodingKey' );

		Test.stopTest();

		for ( Schema.PicklistEntry picklistEntry : picklistEntries ) {
			PicklistUtility.ComboboxValue comboboxValue = new PicklistUtility.ComboboxValue( picklistEntry );

			System.assertEquals( picklistEntry.getLabel(), comboboxValue.label );
			System.assertEquals( picklistEntry.getValue(), comboboxValue.value );
		}
	}

	@IsTest
	static void testSchemaModelCombobox() {
		Test.startTest();
		SchemaService.SchemaModel userSchemaModel = SchemaService.getSchemaModel( 'User' );

		PicklistUtility.ComboboxValue schemaModelComboboxValue = new PicklistUtility.ComboboxValue( userSchemaModel );
		PicklistUtility.ComboboxValue fieldModelComboboxValue = new PicklistUtility.ComboboxValue( userSchemaModel.fields[0] );

		List<PicklistUtility.ComboboxValue> fieldComboboxValues = PicklistUtility.getComboboxValues(userSchemaModel.fields);

		Test.stopTest();

		System.assertEquals( 'User', userSchemaModel.value, 'SOBject value should match' );

		System.assertEquals( userSchemaModel.label, schemaModelComboboxValue.label, 'Label property values should match' );
		System.assertEquals( userSchemaModel.value, schemaModelComboboxValue.value, 'Value property values should match' );

		String expectedFieldModelLabel = String.format('{0} ({1})', new List<String>{
			userSchemaModel.fields[0].label,
			userSchemaModel.fields[0].type.toLowerCase().capitalize()
		});
		System.assertEquals( expectedFieldModelLabel, fieldModelComboboxValue.label, 'Label property values should match' );
		System.assertEquals( userSchemaModel.fields[0].value, fieldModelComboboxValue.value, 'Value property values should match' );

		System.assert(userSchemaModel.fields.size() == fieldComboboxValues.size(), 'Both lists should maintain the same count of items');



		/* String recordTypeJson = '{"Name":"test record
		  *
		  *      type","IsActive":true,"DeveloperName":"TestRecordType","SobjectType":"User","Id":"000123456"}';
		  *
		  *  Schema.RecordTypeInfo recordTypeInfo = (Schema.RecordTypeInfo)JSON.deserialize( recordTypeJson,
		  *  Schema.RecordTypeInfo.class );
		  *
		  *  SchemaService.RecordTypeModel recordTypeModel = new SchemaService.RecordTypeModel( recordTypeInfo
		  *  );
		  *  userSchemaModel.recordTypes.add( recordTypeModel );
		  *
		  *  Not testable? maybe deserialize recordTypeInfo from JSON? Nope, that doesn't work.
		  *  PicklistUtility.ComboboxValue recordTypeModelComboboxValue = new PicklistUtility.ComboboxValue(
		  *  userSchemaModel.recordTypes[0] ); */
	}

	@IsTest
	static void testComboboxList(){

		List<SchemaService.SchemaItem> schemaItems = new List<SchemaService.SchemaItem>();
		SchemaService.SchemaItem schemaItem = new SchemaService.SchemaItem();
		schemaItem.label = 'label';
		schemaItem.value = 'value';
		schemaItems.add(schemaItem);

		Test.startTest();

		List<PicklistUtility.ComboboxValue> comboboxValues = PicklistUtility.getComboboxValues(schemaItems);

		Test.stopTest();

		System.assertEquals(false, comboboxValues.isEmpty(), 'List should be populated');
	}

	@IsTest
	static void testObjectMappingCombobox() {
		MappingService.ObjectMapping objectMapping = new MappingService.ObjectMapping();
		objectMapping.destinationObjectLabel = 'Object Label';
		objectMapping.destinationObject = 'Object_API_Name';

		MappingService.FieldMapping fieldMapping = new MappingService.FieldMapping();
		fieldMapping.destinationLabel = 'Field Label';
		fieldMapping.destination = 'Field_API_Name';

		MappingService.RecordTypes recordTypeMapping = new MappingService.RecordTypes();
		recordTypeMapping.destinationLabel = 'Record Type Name';
		recordTypeMapping.recordTypeId = 'recordTypeIdValue';

		Test.startTest();

		PicklistUtility.ComboboxValue objectMappingComboboxValue = new PicklistUtility.ComboboxValue( objectMapping );
		PicklistUtility.ComboboxValue fieldMappingComboboxValue = new PicklistUtility.ComboboxValue( fieldMapping );
		PicklistUtility.ComboboxValue recordTypeMappingComboboxValue = new PicklistUtility.ComboboxValue( recordTypeMapping );

		Test.stopTest();

		System.assertEquals( objectMapping.destinationObjectLabel, objectMappingComboboxValue.label, 'Label/destinationObjectLabel property values should match' );
		System.assertEquals( objectMapping.destinationObject, objectMappingComboboxValue.value, 'Value/destinationObject property values should match' );

		System.assertEquals( fieldMapping.destinationLabel, fieldMappingComboboxValue.label, 'Label/destinationLabel property values should match' );
		System.assertEquals( fieldMapping.destination, fieldMappingComboboxValue.value, 'Value/destination property values should match' );

		System.assertEquals( recordTypeMapping.destinationLabel, recordTypeMappingComboboxValue.label, 'Label/destinationLabel property values should match' );
		System.assertEquals( recordTypeMapping.destination, recordTypeMappingComboboxValue.value, 'Value/destination property values should match' );
	}
}