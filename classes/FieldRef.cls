/**
 * FieldRef 
 * Used by Utilities class to handle various field reference use cases. Such as Field__c, __r.Field__c or multi level references.
 */
public abstract class FieldRef {
    public abstract Object getFrom(sObject record);

    public static FieldRef build( Schema.SObjectField field ) {
        return new SchemaFieldRef( field );
    }

    public static FieldRef build(String field)
    {
        Integer index = field.indexOf('.');
        if (index == -1) {
            return new SimpleFieldRef( field );
        }

        return new ChainedFieldRef(field.substring(0, index), build(field.substring(index + 1)));
    }

    public virtual class SchemaFieldRef extends FieldRef {
        @TestVisible Schema.SObjectField field;

        public SchemaFieldRef(Schema.SObjectField field) {
            this.field = field;
        }

        public override Object getFrom(sObject record) {
            return record.get(field);
        }

        public override String toString() {
            return '' + field;
        }
    }

    public virtual class SimpleFieldRef extends FieldRef {
        @TestVisible String field;

        public SimpleFieldRef(String field) {
            this.field = field;
        }

        public override Object getFrom(sObject record) {
            return record.get(field);
        }

        public override String toString() {
            return field;
        }
    }

    public virtual class ChainedFieldRef extends FieldRef {
        @TestVisible String field;
        @TestVisible FieldRef next;

        public ChainedFieldRef(String field, FieldRef next) {
            this.field = field;
            this.next = next;
        }

        public override Object getFrom(sObject record) {
            sObject parent = record.getSObject(field);

            return parent == null ? null : next.getFrom(parent);
        }

        public override String toString() {
            return field + '.' + next.toString();
        }
    }
}