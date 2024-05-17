@isTest
private class FieldRefTest { 
    static final Schema.SObjectField SOBJFIELD = Lead.FirstName;
    static final String FIELD = 'Field__c';
    static final String RELATIONSHIP = 'Parent__c';
    static final String REFERENCE = RELATIONSHIP + '.' + FIELD;
    static final String NAME = 'Jon';
    static final String COMPANY = 'Winterfell';

    static testMethod void build_Schema() {

        Test.startTest();
            FieldRef ref = FieldRef.build( SOBJFIELD );
        Test.stopTest();

        System.assert(ref instanceof FieldRef.SchemaFieldRef);
        System.assertEquals(SOBJFIELD, ((FieldRef.SchemaFieldRef)ref).field);
    }

    static testMethod void build_Simple(){

        Test.startTest();
            FieldRef ref = FieldRef.build(FIELD);
        Test.stopTest();

        System.assert(ref instanceof FieldRef.SimpleFieldRef);
        System.assertEquals(FIELD, ((FieldRef.SimpleFieldRef)ref).field);
    }

    static testMethod void build_Chained() {

        Test.startTest();
            FieldRef ref = FieldRef.build(REFERENCE);
        Test.stopTest();

        System.assert( ref instanceof FieldRef.ChainedFieldRef);
        FieldRef.ChainedFieldRef parent = (FieldRef.ChainedFieldRef)ref;
        System.assertEquals(RELATIONSHIP, parent.field);
        System.assert(parent.next instanceof FieldRef.SimpleFieldRef);
        System.assertEquals(FIELD, ((FieldRef.SimpleFieldRef)parent.next).field);
    }

    static testMethod void getFrom_Schema() {
        Lead jonSnow = new Lead(FirstName = NAME );
        FieldRef firstName = new FieldRef.SchemaFieldRef(Lead.FirstName);

        Test.startTest();
            Object retrieved = firstName.getFrom(jonSnow);
        Test.stopTest();

        System.assertEquals(NAME, retrieved);
    }

    static testMethod void getFrom_Simple() {
        Lead jonSnow = new Lead(FirstName = NAME);
        FieldRef firstName = new FieldRef.SimpleFieldRef('FirstName');

        Test.startTest();

            Object retrieved = firstName.getFrom(jonSnow);

        Test.stopTest();

        System.assertEquals(NAME, retrieved);
    }

    static testMethod void getFrom_Chained() {
        Account winterfell = new Account(Name = COMPANY);
        Contact jonSnow = new Contact(FirstName = 'Jon');
        jonSnow.putSObject('Account', winterfell);

        FieldRef child = new FieldRef.SimpleFieldRef('Name');
        FieldRef accountName = new FieldRef.ChainedFieldRef('Account', child);

        Test.startTest();
            Object retrieved = accountName.getFrom(jonSnow);
        Test.stopTest();

        System.assertEquals(COMPANY, retrieved);
    }

    static testMethod void getFrom_Chained_Null() {
        Contact orphan = new Contact(FirstName = 'Jon');
        FieldRef child = new FieldRef.SimpleFieldRef('Name');
        FieldRef accountName = new FieldRef.ChainedFieldRef('Account', child);

        Test.startTest();
            Object retrieved = accountName.getFrom(orphan);
        Test.stopTest();

        System.assertEquals(null, retrieved);
    }

    static testMethod void toString_Schema() {
        FieldRef firstName = new FieldRef.SchemaFieldRef(Lead.FirstName);

        Test.startTest();
            String field = firstName.toString();
        Test.stopTest();

        System.assertEquals('FirstName', field);
    }

    static testMethod void toString_Simple() {
        FieldRef firstName = new FieldRef.SimpleFieldRef('FirstName');

        Test.startTest();
            String field = firstName.toString();
        Test.stopTest();

        System.assertEquals('FirstName', field);
    }

    static testMethod void toString_Chained() {
        FieldRef child = new FieldRef.SimpleFieldRef('Name');
        FieldRef accountName = new FieldRef.ChainedFieldRef('Account', child);

        Test.startTest();
            String field = accountName.toString();
        Test.stopTest();

        System.assertEquals('Account.Name', field);
    }
}