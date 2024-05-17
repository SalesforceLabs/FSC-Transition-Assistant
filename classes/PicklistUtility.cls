public inherited sharing class PicklistUtility {

	@AuraEnabled( cacheable = true )
	public static List<ComboboxValue> getComboboxValues(List<SchemaService.SchemaItem> schemaItems) {

		List<ComboboxValue> values = new List<ComboboxValue>();

		for(SchemaService.SchemaItem schemaItem : schemaItems){
			if( schemaItem instanceOf SchemaService.RecordTypeModel){
				values.add( new ComboboxValue((SchemaService.RecordTypeModel)schemaItem) );
			} else if( schemaItem instanceOf SchemaService.FieldModel){
				values.add( new ComboboxValue((SchemaService.FieldModel)schemaItem) );
			} else {
				values.add( new ComboboxValue(schemaItem));
			}

		}

		return values;
	}

	public class ComboboxValue {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String value;

		public ComboboxValue( Schema.PicklistEntry picklistEntry ) {
			this.label = picklistEntry.getLabel();
			this.value = picklistEntry.getValue();
		}

		public ComboboxValue( String value, String label ) {
			this.label = label;
			this.value = value;
		}

		public ComboboxValue(SchemaService.SchemaItem schemaItem){
			this.label = schemaItem.label;
			this.value = schemaItem.value;
		}

		public ComboboxValue(SchemaService.RecordTypeModel schemaItem){
			this.label = String.format('{0} (Total: {1})', new List<Object>{
				schemaItem.label,
				schemaItem.recordCount
			});
			this.value = schemaItem.value;
		}

		public ComboboxValue(SchemaService.FieldModel schemaItem){
			this.label = String.format('{0} ({1})', new List<String>{
				schemaItem.label,
				schemaItem.type.toLowerCase().capitalize()
			});
			this.value = schemaItem.value;
		}

		public ComboboxValue( MappingService.ObjectMapping objectMapping ) {
			// TODO? Assuming "Destination" is the FSC object, and "Source" is the current org
			this.label = objectMapping.destinationObjectLabel;
			this.value = objectMapping.destinationObject;
		}


		public ComboboxValue( MappingService.MappingItem mappingItem ) {
			// TODO? Assuming "Destination" is the FSC object, and "Source" is the current org
			this.label = mappingItem.destinationLabel;
			this.value = mappingItem.destination;
		}
	}
}