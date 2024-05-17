@IsTest
private class UtilitiesTest
{
    private static testMethod void namespaceTest(){
        Test.startTest();
            String ns = Utilities.namespace;
            String nsDot = Utilities.namespaceDot;
            String nsUnder = Utilities.namespaceUnderscore;
        Test.stopTest();
        System.assertNotEquals(null, ns, 'Namespace should not be null either empty string or package namespace');
        System.assertNotEquals(null, nsDot, 'Namespace with dot should not be null either empty string or with package namespace');
        System.assertNotEquals(null, nsUnder, 'Namespace with underscored should not be null either empty string or with package namespace');
    }

    private static testMethod void namespacedObjectTest(){
        System.assertNotEquals(null, Utilities.getNamespacedObject('Foobar__c'));
    }
    
    private static testMethod void testGroupByDates()
    {
        final Date TOMORROW = Date.today().addDays(1);
        final Date NEXT_WEEK = Date.today().addDays(7);

        Opportunity opportunityTomorrow1 =
            new Opportunity( Id = '0067000000N0aqdAAB', CloseDate = TOMORROW );
        Opportunity opportunityTomorrow2 =
            new Opportunity( Id = '0067000000N0aqdAAC', CloseDate = TOMORROW );
        Opportunity opportunityNextWeek  =
            new Opportunity( Id = '0067000000N0aqdAAD', CloseDate = NEXT_WEEK );

        Map<Date, Set<Id>> dateToExpectedIds = new Map<Date, Set<Id>>{
            TOMORROW => new Set<Id>{ opportunityTomorrow1.Id, opportunityTomorrow2.Id },
            NEXT_WEEK => new Set<Id>{ opportunityNextWeek.Id }
        };

        List<sObject> opportunities = new List<Opportunity>{
            opportunityTomorrow1,
            opportunityTomorrow2,
            opportunityNextWeek
        };

        Test.startTest();

            Map<Date, List<sObject>> dateToOpportunities = Utilities.groupByDates( 'CloseDate', opportunities );
            Map<Date, List<sObject>> dateToOpportunitiesSF = Utilities.groupByDates( Opportunity.CloseDate, opportunities );

        Test.stopTest();

        System.assertEquals( 2, dateToOpportunities.size(),
            'All Close Dates should be keys in the map' );

        for( Date aDate : dateToOpportunities.keySet() )
        {
            System.assert( dateToExpectedIds.containsKey( aDate ),
                'Each Close Date should be a key in the map' );

            Set<Id> expectedIds = dateToExpectedIds.get( aDate );
            List<sObject> actualOpportunities = dateToOpportunities.get( aDate );

            System.assertEquals( expectedIds.size(), actualOpportunities.size(),
                'All the Opportunities should be in the value list' );

            for ( sObject opportunity : actualOpportunities )
            {
                System.assert( expectedIds.contains( opportunity.Id ),
                    'Each of the Opportunties should be in the value list' );
            }
        }

        System.assertEquals(dateToOpportunities, dateToOpportunitiesSF, 'The sobject field version should produce the same map');
    }

    private static testMethod void testGroupByDatetimes()
    {
        final Datetime TOMORROW = DateTime.now().addDays(1);
        final Datetime NEXT_WEEK = DateTime.now().addDays(7);

        Event birthdayParty = new Event( Id = '00U0000000XXXXU', ActivityDateTime = TOMORROW );
        Event cookout = new Event( Id = '00U0000000XXXXW', ActivityDateTime = TOMORROW );
        Event boxSocial = new Event( Id = '00U0000000XXXXX', ActivityDateTime = NEXT_WEEK );

        Map<DateTime, Set<Id>> datetimeToExpectedIds = new Map<DateTime, Set<Id>>{
            TOMORROW => new Set<Id>{ birthdayParty.Id, cookout.Id },
            NEXT_WEEK => new Set<Id>{ boxSocial.Id }
        };

        List<sObject> events = new List<Event>{
            birthdayParty,
            cookout,
            boxSocial
        };

        Test.startTest();

            Map<DateTime, List<sObject>> datetimeToEvents = Utilities.groupByDatetimes( 'ActivityDateTime', events );
            Map<DateTime, List<sObject>> datetimeToEventsSF = Utilities.groupByDatetimes( Event.ActivityDateTime, events );

        Test.stopTest();

        System.assertEquals( 2, datetimeToEvents.size(),
            'All Activity Dates should be keys in the map' );

        for( DateTime aDateTime : datetimeToEvents.keySet() )
        {
            System.assert( datetimeToExpectedIds.containsKey( aDateTime ),
                'Each Activity Date should be a key in the map' );

            Set<Id> expectedIds = datetimeToExpectedIds.get( aDateTime );
            List<sObject> actualEvents = datetimeToEvents.get( aDateTime );

            System.assertEquals( expectedIds.size(), actualEvents.size(),
                'All the Events should be in the value list' );

            for ( sObject anEvent : actualEvents )
            {
                System.assert( expectedIds.contains( anEvent.Id ),
                    'Each of the Events should be in the value list' );
            }
        }

        System.assertEquals(datetimeToEvents, datetimeToEventsSF, 'The sobject field version should produce the same map');
    }

    private static testMethod void testGroupByDecimals()
    {
        final Decimal LOTS_OF_MONEY = 42069.96;
        final Decimal NOT_MUCH_MONEY = 2.11;

        Opportunity bigSale =
            new Opportunity( Id = '0067000000N0aqdAAB', Amount = LOTS_OF_MONEY );
        Opportunity anotherBigSale =
            new Opportunity( Id = '0067000000N0aqdAAC', Amount = LOTS_OF_MONEY );
        Opportunity smallSale =
            new Opportunity( Id = '0067000000N0aqdAAD', Amount = NOT_MUCH_MONEY );

        Map<Decimal, Set<Id>> decimalToExpectedIds = new Map<Decimal, Set<Id>>{
            LOTS_OF_MONEY => new Set<Id>{ bigSale.Id, anotherBigSale.Id },
            NOT_MUCH_MONEY => new Set<Id>{ smallSale.Id }
        };

        List<sObject> opportunities = new List<Opportunity>{
            bigSale,
            anotherBigSale,
            smallSale
        };

        Test.startTest();

            Map<Decimal, List<sObject>> decimalToOpportunities = Utilities.groupByDecimals( 'Amount', opportunities );
            Map<Decimal, List<sObject>> decimalToOpportunitiesSF = Utilities.groupByDecimals( Opportunity.Amount, opportunities );

        Test.stopTest();

        System.assertEquals( 2, decimalToOpportunities.size(),
            'All Amounts should be keys in the map' );

        for( Decimal aDecimal : decimalToOpportunities.keySet() )
        {
            System.assert( decimalToExpectedIds.containsKey( aDecimal ),
                'Each Amount should be a key in the map' );

            Set<Id> expectedIds = decimalToExpectedIds.get( aDecimal );
            List<sObject> actualOpportunities = decimalToOpportunities.get( aDecimal );

            System.assertEquals( expectedIds.size(), actualOpportunities.size(),
                'All the Opportunities should be in the value list' );

            for ( sObject opportunity : actualOpportunities )
            {
                System.assert( expectedIds.contains( opportunity.Id ),
                    'Each of the Opportunties should be in the value list' );
            }
        }

        System.assertEquals(decimalToOpportunities, decimalToOpportunitiesSF, 'The sobject field version should produce the same map');
    }

    private static testMethod void testGroupByIntegers()
    {
        final Integer SMALL_FIRM = 75;
        final Integer TINY_FIRM = 3;

        Account smallAccount = new Account( Id = '0017000000N0aqdAAA', NumberOfEmployees = SMALL_FIRM );
        Account littleAccount = new Account( Id = '0017000000N0aqdAAB', NumberOfEmployees = SMALL_FIRM );
        Account tinyAccount = new Account( Id = '0017000000N0aqdAAC', NumberOfEmployees = TINY_FIRM );

        Map<Integer, Set<Id>> integerToExpectedIds = new Map<Integer, Set<Id>>{
            SMALL_FIRM => new Set<Id>{ smallAccount.Id, littleAccount.Id },
            TINY_FIRM => new Set<Id>{ tinyAccount.Id }
        };

        List<sObject> accounts = new List<Account>{
            smallAccount,
            littleAccount,
            tinyAccount
        };

        Test.startTest();

            Map<Integer, List<sObject>> integerToAccounts = Utilities.groupByIntegers( 'NumberOfEmployees', accounts );
            Map<Integer, List<sObject>> integerToAccountsSF = Utilities.groupByIntegers( Account.NumberOfEmployees, accounts );

        Test.stopTest();

        System.assertEquals( 2, integerToAccounts.size(),
            'All Number of Employees should be keys in the map' );

        for ( Integer anInteger : integerToAccounts.keySet() )
        {
            System.assert( integerToExpectedIds.containsKey( anInteger ),
                'Each Number of Employees should be a key in the map' );

            Set<Id> expectedIds = integerToExpectedIds.get( anInteger );
            List<sObject> actualAccounts = integerToAccounts.get( anInteger );

            System.assertEquals( expectedIds.size(), actualAccounts.size(),
                'All the Accounts should be in the value list' );

            for ( sObject account : actualAccounts )
            {
                System.assert( expectedIds.contains( account.Id ),
                    'Each of the Accounts should be in the value list' );
            }
        }

        System.assertEquals(integerToAccounts, integerToAccountsSF, 'The sobject field version should produce the same map');
    }

    private static testMethod void testGroupByIds()
    {
        final Id OPPORTUNITY_1 = '0067000000Us9A1AAJ';
        final Id OPPORTUNITY_2 = '0069000000Us7U1AAN';

        OpportunityLineItem opportunity1Product1 =
            new OpportunityLineItem( Id = '00k7000000N0aqdAAB', OpportunityId = OPPORTUNITY_1 );
        OpportunityLineItem opportunity1Product2  =
            new OpportunityLineItem( Id = '00k7000000N0aqdAAC', OpportunityId = OPPORTUNITY_1 );
        OpportunityLineItem opportunity2Product1  =
            new OpportunityLineItem( Id = '00k7000000N0aqdAAD', OpportunityId = OPPORTUNITY_2 );

        Map<Id, Set<Id>> opportunityIdToExpectedIds = new Map<Id, Set<Id>>{
            OPPORTUNITY_1 => new Set<Id>{ opportunity1Product1.Id, opportunity1Product2.Id },
            OPPORTUNITY_2 => new Set<Id>{ opportunity2Product1.Id }
        };

        List<sObject> olis = new List<OpportunityLineItem>{
            opportunity2Product1,
            opportunity1Product1,
            opportunity1Product2
        };

        Test.startTest();

            Map<Id, List<sObject>> opportunityIdToOLIs = Utilities.groupByIds( 'OpportunityId', olis );
            Map<Id, List<sObject>> opportunityIdToOLIsSF = Utilities.groupByIds( OpportunityLineItem.OpportunityId, olis );

        Test.stopTest();

        System.assertEquals( 2, opportunityIdToOLIs.size(),
            'All Opportunity Ids should be keys in the map' );

        for( Id opportunityId : opportunityIdToOLIs.keySet() )
        {
            System.assert( opportunityIdToExpectedIds.containsKey( opportunityId ),
                'Each Opportunity Id should be a key in the map' );

            Set<Id> expectedIds = opportunityIdToExpectedIds.get( opportunityId );
            List<sObject> actualOLIs = opportunityIdToOLIs.get( opportunityId );

            System.assertEquals( expectedIds.size(), actualOLIs.size(),
                'All the OLIs should be in the value list' );

            for ( sObject oli : actualOLIs )
            {
                System.assert( expectedIds.contains( oli.Id ),
                    'Each of the child OLIs should be in the value list' );
            }
        }

        System.assertEquals(opportunityIdToOLIs, opportunityIdToOLIsSF, 'The sobject field version should produce the same map');
    }

    private static testMethod void testGroupByStrings()
    {
        final String JOHNNY = 'Johnny';
        final String JULIE = 'Julie';

        Lead johnnyLead = new Lead( Id = '00Q0000000XXXXX', FirstName = JOHNNY );
        Lead julieLead = new Lead( Id = '00Q0000000XXXXY', FirstName = JULIE );
        Lead julie2Lead = new Lead( Id = '00Q0000000XXXXZ', FirstName = JULIE );

        Map<String, Set<Id>> stringToExpectedIds = new Map<String, Set<Id>>{
            JOHNNY => new Set<Id>{ johnnyLead.Id },
            JULIE => new Set<Id>{ julieLead.Id, julie2Lead.Id }
        };

        List<sObject> leads = new List<sObject>{
            johnnyLead,
            julieLead,
            julie2Lead
        };

        Test.startTest();

            Map<String, List<sObject>> stringToLeads = Utilities.groupByStrings( 'FirstName', leads );
            Map<String, List<sObject>> stringToLeadsSF = Utilities.groupByStrings( Lead.FirstName, leads );

        Test.stopTest();

        System.assertEquals( 2, stringToLeads.size(),
            'All the First Names should be keys in the map' );

        for ( String aString : stringToLeads.keySet() )
        {
            System.assert( stringToExpectedIds.containsKey( aString ),
                'Each of the First names should be keys in the map' );

            Set<Id> expectedIds = stringToExpectedIds.get( aString );
            List<sObject> actualLeads = stringToLeads.get( aString );

            System.assertEquals( expectedIds.size(), actualLeads.size(),
                'All the Leads should be in the value list' );

            for ( sObject lead : actualLeads )
            {
                System.assert( expectedIds.contains( lead.Id ),
                    'Each of the Leads should be in the value list' );
            }
        }

        System.assertEquals(stringToLeads, stringToLeadsSF, 'The sobject field version should produce the same map');
    }

    static testMethod void testGroupByBooleans() {
        Contact doNotCall = new Contact(LastName='test',DoNotCall=true);
        Contact doNotCall2 = new Contact(LastName='test2',DoNotCall=true);
        Contact doCall = new Contact(LastName='test3',DoNotCall=false);

        List<Contact> contacts = new List<Contact>{doNotCall,doNotCall2,doCall};

        Test.startTest();
            Map<Boolean, List<Contact>> booleanToContacts = Utilities.groupByBooleans('DoNotCall', contacts);
            Map<Boolean, List<Contact>> booleanToContactsSF = Utilities.groupByBooleans(Contact.DoNotCall, contacts);
        Test.stopTest();

        System.assertEquals(2, booleanToContacts.size(), 'There should be the correct number of key value pairs');
        System.assertEquals(2, booleanToContacts.get(true).size(), 'There should be the correct number of contacts');
        for(Contact contact : booleanToContacts.get(true)) {
            System.assert(contact.DoNotCall, 'The correct contacts should be in the list');
        }
        System.assertEquals(1, booleanToContacts.get(false).size(), 'There should be the correct number of contacts');
        System.assert(!booleanToContacts.get(false)[0].DoNotCall, 'The correct contact should be in the list');

        System.assertEquals(booleanToContacts, booleanToContactsSF, 'The sobject field version should produce the same map');
    }

    private static testMethod void parseObjectValueTestObj() {
        String attributeFieldPath = 'field1.field2.field3';
        String confirmValue = 'hello world';
        String testTypeObjJson = '{"field1":{"field2":{"field3":"'+confirmValue+'"}}}';
        Object testTypeObj = JSON.deserializeUntyped(testTypeObjJson);

        Test.startTest();
            Object fieldValue = Utilities.parseObjectValue(attributeFieldPath, testTypeObj);
        Test.stopTest();

        System.assertEquals(confirmValue, fieldValue, 'confirmValue must be parsed out of the testTypeObj with the defined attributeFieldPath');
    }

    private static testMethod void parseObjectValueTestList() {
        String attributeFieldPath = 'field1.field2.field3';
        String confirmValue = 'hello world';
        String testTypeObjJson = '{"field1":{"field2":[{"field3":"'+confirmValue+'"}]}}';
        Object testTypeObj = JSON.deserializeUntyped(testTypeObjJson);

        Test.startTest();
            Object fieldValue = Utilities.parseObjectValue(attributeFieldPath, testTypeObj);
        Test.stopTest();

        System.assertEquals(confirmValue, fieldValue, 'confirmValue must be parsed out of the testTypeObj with the defined attributeFieldPath');
    }

    private static testMethod void pluckTest()
    {
        Lead johnny = new Lead( FirstName = 'Johnny', LastName = 'Five', Company = 'Johnny Co' );

        Test.startTest();
            Object actualName = Utilities.pluck( 'FirstName', johnny );
        Test.stopTest();

        System.assertEquals( johnny.FirstName, actualName, 'The sObject Name should be plucked' );
    }

    private static testMethod void pluckTest_SObjectField()
    {
        Lead johnny = new Lead( FirstName = 'Johnny', LastName = 'Five', Company = 'Johnny Co' );

        Test.startTest();
            Object actualName = Utilities.pluck( Lead.FirstName, johnny );
        Test.stopTest();

        System.assertEquals( johnny.FirstName, actualName, 'The sObject Name should be plucked' );
    }

    private static testMethod void pluckIgnoresNulls()
    {
        Lead johnny = new Lead();

        Test.startTest();
            Set<Object> actualIds = Utilities.pluck( FieldRef.build( 'Id' ), new List<sObject>{ johnny } );
        Test.stopTest();

        System.assert( actualIds.isEmpty(), 'null values should be ignored' );
    }

    private static testMethod void pluckBulkTest()
    {
        Lead johnny = new Lead( FirstName = 'Johnny', LastName = 'Five', Company = 'Johnny Co' );
        Lead julie  = new Lead( FirstName = 'Julie', LastName = 'Five', Company = 'Julie Co' );
        Lead jamby = new Lead( FirstName = 'Jamby', LastName = 'Five', Company = 'Jamby Co' );

        List<Lead> allLeads = new List<Lead>{ johnny, julie, jamby };

        Test.startTest();
            Set<Object> actualNames = Utilities.pluck( 'FirstName', allLeads );
        Test.stopTest();

        System.assert( actualNames.contains( johnny.FirstName ), 'The FirstNames of the sObjects should be plucked' );
        System.assert( actualNames.contains( julie.FirstName ), 'The FirstNames of the sObjects should be plucked' );
        System.assert( actualNames.contains( jamby.FirstName ), 'The FirstNames of the sObjects should be plucked' );
    }

    private static testMethod void pluckBulkTest_SObjectField()
    {
        Lead johnny = new Lead( FirstName = 'Johnny', LastName = 'Five', Company = 'Johnny Co' );
        Lead julie  = new Lead( FirstName = 'Julie', LastName = 'Five', Company = 'Julie Co' );
        Lead jamby = new Lead( FirstName = 'Jamby', LastName = 'Five', Company = 'Jamby Co' );

        List<Lead> allLeads = new List<Lead>{ johnny, julie, jamby };

        Test.startTest();
            Set<Object> actualNames = Utilities.pluck( Lead.FirstName, allLeads );
        Test.stopTest();

        System.assert( actualNames.contains( johnny.FirstName ), 'The FirstNames of the sObjects should be plucked' );
        System.assert( actualNames.contains( julie.FirstName ), 'The FirstNames of the sObjects should be plucked' );
        System.assert( actualNames.contains( jamby.FirstName ), 'The FirstNames of the sObjects should be plucked' );
    }

    private static testMethod void pluckDateTest()
    {
        Date tomorrow = Date.today().addDays(1);
        Opportunity bigSale = new Opportunity( Name = 'Sell a lot', CloseDate = tomorrow, StageName = 'Qualification' );

        Test.startTest();
            Date actualDate = Utilities.pluckDate( 'CloseDate', bigSale );
        Test.stopTest();

        System.assertEquals( tomorrow, actualDate, 'The sObject Created Date should be plucked' );
    }

    private static testMethod void pluckDateTest_SObjectField()
    {
        Date tomorrow = Date.today().addDays(1);
        Opportunity bigSale = new Opportunity( Name = 'Sell a lot', CloseDate = tomorrow, StageName = 'Qualification' );

        Test.startTest();
            Date actualDate = Utilities.pluckDate( Opportunity.CloseDate, bigSale );
        Test.stopTest();

        System.assertEquals( tomorrow, actualDate, 'The sObject Created Date should be plucked' );
    }

    private static testMethod void pluckDatesIgnoresNulls()
    {
        Lead johnny = new Lead();

        Test.startTest();
            Set<Date> actualDates = Utilities.pluckDates( FieldRef.build( 'CreatedDate' ), new List<sObject>{ johnny } );
        Test.stopTest();

        System.assert( actualDates.isEmpty(), 'null values should be ignored' );
    }

    private static testMethod void pluckDatesTest()
    {
        Date tomorrow = Date.today().addDays(1);
        Date nextWeek = Date.today().addDays(7);
        Date nextMonth = Date.today().addDays(30);
        Opportunity bigSale = new Opportunity( Name = 'Sell a lot', CloseDate = tomorrow, StageName = 'Qualification' );
        Opportunity biggerSale = new Opportunity( Name = 'Sell it all', CloseDate = nextWeek, StageName = 'Qualification' );
        Opportunity biggestSale = new Opportunity( Name = 'Permanent vacation', CloseDate = nextMonth, StageName = 'Qualification' );

        List<Opportunity> allOpportunitiesList = new List<Opportunity>{ bigSale, biggerSale, biggestSale };
        Map<Id, Opportunity> allOpportunitiesMap = new Map<Id, Opportunity>{
            '00Q0000000XXXXX' => bigSale,
            '00Q0000000XXXXY' => biggerSale,
            '00Q0000000XXXXZ' => biggestSale
        };

        Test.startTest();
            Set<Date> actualDatesList = Utilities.pluckDates( 'CloseDate', allOpportunitiesList );
            Set<Date> actualDatesMap = Utilities.pluckDates( 'CloseDate', allOpportunitiesMap );
        Test.stopTest();

        System.assert( actualDatesList.contains( tomorrow ), 'The sObject Close Date should be plucked' );
        System.assert( actualDatesList.contains( nextWeek ), 'The sObject Close Date should be plucked' );
        System.assert( actualDatesList.contains( nextMonth ), 'The sObject Close Date should be plucked' );
        System.assert( actualDatesMap.contains( tomorrow ), 'The sObject Close Date should be plucked' );
        System.assert( actualDatesMap.contains( nextWeek ), 'The sObject Close Date should be plucked' );
        System.assert( actualDatesMap.contains( nextMonth ), 'The sObject Close Date should be plucked' );
    }

    private static testMethod void pluckDatesTest_SObjectField()
    {
        Date tomorrow = Date.today().addDays(1);
        Date nextWeek = Date.today().addDays(7);
        Date nextMonth = Date.today().addDays(30);
        Opportunity bigSale = new Opportunity( Name = 'Sell a lot', CloseDate = tomorrow, StageName = 'Qualification' );
        Opportunity biggerSale = new Opportunity( Name = 'Sell it all', CloseDate = nextWeek, StageName = 'Qualification' );
        Opportunity biggestSale = new Opportunity( Name = 'Permanent vacation', CloseDate = nextMonth, StageName = 'Qualification' );

        List<Opportunity> allOpportunitiesList = new List<Opportunity>{ bigSale, biggerSale, biggestSale };
        Map<Id, Opportunity> allOpportunitiesMap = new Map<Id, Opportunity>{
            '00Q0000000XXXXX' => bigSale,
            '00Q0000000XXXXY' => biggerSale,
            '00Q0000000XXXXZ' => biggestSale
        };

        Test.startTest();
            Set<Date> actualDatesList = Utilities.pluckDates( Opportunity.CloseDate, allOpportunitiesList );
            Set<Date> actualDatesMap = Utilities.pluckDates( Opportunity.CloseDate, allOpportunitiesMap );
        Test.stopTest();

        System.assert( actualDatesList.contains( tomorrow ), 'The sObject Close Date should be plucked' );
        System.assert( actualDatesList.contains( nextWeek ), 'The sObject Close Date should be plucked' );
        System.assert( actualDatesList.contains( nextMonth ), 'The sObject Close Date should be plucked' );
        System.assert( actualDatesMap.contains( tomorrow ), 'The sObject Close Date should be plucked' );
        System.assert( actualDatesMap.contains( nextWeek ), 'The sObject Close Date should be plucked' );
        System.assert( actualDatesMap.contains( nextMonth ), 'The sObject Close Date should be plucked' );
    }

    private static testMethod void pluckDatetimeTest()
    {
        Event birthdayParty = new Event( ActivityDateTime = DateTime.now() );

        Test.startTest();
            Datetime actualDatetime = Utilities.pluckDatetime( 'ActivityDateTime', birthdayParty );
        Test.stopTest();

        System.assertEquals( birthdayParty.ActivityDateTime, actualDatetime, 'The sObject Created Date should be plucked' );
    }

    private static testMethod void pluckDatetimeTest_SObjectField()
    {
        Event birthdayParty = new Event( ActivityDateTime = DateTime.now() );

        Test.startTest();
            Datetime actualDatetime = Utilities.pluckDatetime( Event.ActivityDateTime, birthdayParty );
        Test.stopTest();

        System.assertEquals( birthdayParty.ActivityDateTime, actualDatetime, 'The sObject Created Date should be plucked' );
    }

    private static testMethod void pluckDatetimesIgnoresNulls()
    {
        Lead johnny = new Lead();

        Test.startTest();
            Set<Datetime> actualDatetimes = Utilities.pluckDatetimes( FieldRef.build( 'CreatedDate' ), new List<sObject>{ johnny } );
        Test.stopTest();

        System.assert( actualDatetimes.isEmpty(), 'null values should be ignored' );
    }

    private static testMethod void pluckDatetimesTest()
    {
        Event birthdayParty = new Event( ActivityDateTime = DateTime.now() );
        Event cookout = new Event( ActivityDateTime = DateTime.now().addDays( 1 ) );
        Event boxSocial = new Event( ActivityDateTime = DateTime.now().addDays( 2 ) );

        List<Event> allEvents = new List<Event>{ birthdayParty, cookout, boxSocial };
        Map<Id, Event> allEventsMap = new Map<Id, Event>{
            '00Q0000000XXXXU' => birthdayParty,
            '00Q0000000XXXXW' => cookout,
            '00Q0000000XXXXX' => boxSocial
        };

        Test.startTest();
            Set<Datetime> actualDatetimesList = Utilities.pluckDatetimes( 'ActivityDateTime', allEvents );
            Set<Datetime> actualDatetimesMap = Utilities.pluckDatetimes( 'ActivityDateTime', allEventsMap );
        Test.stopTest();

        System.assert( actualDatetimesList.contains( birthdayParty.ActivityDateTime ), 'The sObjects Created Date should be plucked' );
        System.assert( actualDatetimesList.contains( cookout.ActivityDateTime ), 'The sObjects Created Date should be plucked' );
        System.assert( actualDatetimesList.contains( boxSocial.ActivityDateTime ), 'The sObjects Created Date should be plucked' );
        System.assert( actualDatetimesMap.contains( birthdayParty.ActivityDateTime ), 'The sObjects Created Date should be plucked' );
        System.assert( actualDatetimesMap.contains( cookout.ActivityDateTime ), 'The sObjects Created Date should be plucked' );
        System.assert( actualDatetimesMap.contains( boxSocial.ActivityDateTime ), 'The sObjects Created Date should be plucked' );
    }

    private static testMethod void pluckDatetimesTest_SObjectField()
    {
        Event birthdayParty = new Event( ActivityDateTime = DateTime.now() );
        Event cookout = new Event( ActivityDateTime = DateTime.now().addDays( 1 ) );
        Event boxSocial = new Event( ActivityDateTime = DateTime.now().addDays( 2 ) );

        List<Event> allEvents = new List<Event>{ birthdayParty, cookout, boxSocial };
        Map<Id, Event> allEventsMap = new Map<Id, Event>{
            '00Q0000000XXXXU' => birthdayParty,
            '00Q0000000XXXXW' => cookout,
            '00Q0000000XXXXX' => boxSocial
        };

        Test.startTest();
            Set<Datetime> actualDatetimesList = Utilities.pluckDatetimes( Event.ActivityDateTime, allEvents );
            Set<Datetime> actualDatetimesMap = Utilities.pluckDatetimes( Event.ActivityDateTime, allEventsMap );
        Test.stopTest();

        System.assert( actualDatetimesList.contains( birthdayParty.ActivityDateTime ), 'The sObjects Created Date should be plucked' );
        System.assert( actualDatetimesList.contains( cookout.ActivityDateTime ), 'The sObjects Created Date should be plucked' );
        System.assert( actualDatetimesList.contains( boxSocial.ActivityDateTime ), 'The sObjects Created Date should be plucked' );
        System.assert( actualDatetimesMap.contains( birthdayParty.ActivityDateTime ), 'The sObjects Created Date should be plucked' );
        System.assert( actualDatetimesMap.contains( cookout.ActivityDateTime ), 'The sObjects Created Date should be plucked' );
        System.assert( actualDatetimesMap.contains( boxSocial.ActivityDateTime ), 'The sObjects Created Date should be plucked' );
    }

    private static testMethod void pluckDecimalTest()
    {
        Decimal tonsOfMoney = 1337.02;
        Opportunity bigSale = new Opportunity( Name = 'Sell a lot', CloseDate = Date.today(), Amount = tonsOfMoney, StageName = 'Qualification' );

        Test.startTest();
            Decimal actualDecimal = Utilities.pluckDecimal( 'Amount', bigSale );
        Test.stopTest();

        System.assertEquals( tonsOfMoney, actualDecimal, 'The sObject Amount should be plucked' );
    }

    private static testMethod void pluckDecimalTest_SObjectField()
    {
        Decimal tonsOfMoney = 1337.02;
        Opportunity bigSale = new Opportunity( Name = 'Sell a lot', CloseDate = Date.today(), Amount = tonsOfMoney, StageName = 'Qualification' );

        Test.startTest();
            Decimal actualDecimal = Utilities.pluckDecimal( Opportunity.Amount, bigSale );
        Test.stopTest();

        System.assertEquals( tonsOfMoney, actualDecimal, 'The sObject Amount should be plucked' );
    }

    private static testMethod void pluckDecimalsIgnoresNulls()
    {
        Opportunity bigSale = new Opportunity();

        Test.startTest();
            Set<Decimal> actualDecimals = Utilities.pluckDecimals( FieldRef.build( 'Amount' ), new List<sObject>{ bigSale } );
        Test.stopTest();

        System.assert( actualDecimals.isEmpty(), 'null values should be ignored' );
    }

    private static testMethod void pluckDecimalsTest()
    {
        Decimal tonsOfMoney = 1337.02;
        Decimal evenMoreMoney = 42069.96;
        Decimal notALot = 2.13;
        Opportunity bigSale = new Opportunity( Name = 'Sell a lot', CloseDate = Date.today(), Amount = tonsOfMoney, StageName = 'Qualification' );
        Opportunity biggerSale = new Opportunity( Name = 'Sell a lot', CloseDate = Date.today(), Amount = evenMoreMoney, StageName = 'Qualification' );
        Opportunity smallSale = new Opportunity( Name = 'Sell a lot', CloseDate = Date.today(), Amount = notALot, StageName = 'Qualification' );

        List<Opportunity> allOpportunities = new List<Opportunity>{ bigSale, biggerSale, smallSale };
        Map<Id, Opportunity> allOpportunitiesMap = new Map<Id, Opportunity>{
            '00Q0000000XXXXX' => bigSale,
            '00Q0000000XXXXY' => biggerSale,
            '00Q0000000XXXXZ' => smallSale
        };

        Test.startTest();
            Set<Decimal> actualDecimalsList = Utilities.pluckDecimals( 'Amount', allOpportunities );
            Set<Decimal> actualDecimalsMap = Utilities.pluckDecimals( 'Amount', allOpportunitiesMap );
        Test.stopTest();

        System.assert( actualDecimalsList.contains( tonsOfMoney ), 'The sObject Amount should be plucked' );
        System.assert( actualDecimalsList.contains( evenMoreMoney ), 'The sObject Amount should be plucked' );
        System.assert( actualDecimalsList.contains( notALot ), 'The sObject Amount should be plucked' );
        System.assert( actualDecimalsMap.contains( tonsOfMoney ), 'The sObject Amount should be plucked' );
        System.assert( actualDecimalsMap.contains( evenMoreMoney ), 'The sObject Amount should be plucked' );
        System.assert( actualDecimalsMap.contains( notALot ), 'The sObject Amount should be plucked' );
    }

    private static testMethod void pluckDecimalsTest_SObjectField()
    {
        Decimal tonsOfMoney = 1337.02;
        Decimal evenMoreMoney = 42069.96;
        Decimal notALot = 2.13;
        Opportunity bigSale = new Opportunity( Name = 'Sell a lot', CloseDate = Date.today(), Amount = tonsOfMoney, StageName = 'Qualification' );
        Opportunity biggerSale = new Opportunity( Name = 'Sell a lot', CloseDate = Date.today(), Amount = evenMoreMoney, StageName = 'Qualification' );
        Opportunity smallSale = new Opportunity( Name = 'Sell a lot', CloseDate = Date.today(), Amount = notALot, StageName = 'Qualification' );

        List<Opportunity> allOpportunities = new List<Opportunity>{ bigSale, biggerSale, smallSale };
        Map<Id, Opportunity> allOpportunitiesMap = new Map<Id, Opportunity>{
            '00Q0000000XXXXX' => bigSale,
            '00Q0000000XXXXY' => biggerSale,
            '00Q0000000XXXXZ' => smallSale
        };

        Test.startTest();
            Set<Decimal> actualDecimalsList = Utilities.pluckDecimals( Opportunity.Amount, allOpportunities );
            Set<Decimal> actualDecimalsMap = Utilities.pluckDecimals( Opportunity.Amount, allOpportunitiesMap );
        Test.stopTest();

        System.assert( actualDecimalsList.contains( tonsOfMoney ), 'The sObject Amount should be plucked' );
        System.assert( actualDecimalsList.contains( evenMoreMoney ), 'The sObject Amount should be plucked' );
        System.assert( actualDecimalsList.contains( notALot ), 'The sObject Amount should be plucked' );
        System.assert( actualDecimalsMap.contains( tonsOfMoney ), 'The sObject Amount should be plucked' );
        System.assert( actualDecimalsMap.contains( evenMoreMoney ), 'The sObject Amount should be plucked' );
        System.assert( actualDecimalsMap.contains( notALot ), 'The sObject Amount should be plucked' );
    }

    private static testMethod void pluckIntegerTest()
    {
        Integer smallFirm = 60;
        Account smallAccount = new Account( NumberOfEmployees = smallFirm );

        Test.startTest();
            Integer actualInteger = Utilities.pluckInteger( 'NumberOfEmployees', smallAccount );
        Test.stopTest();

        System.assertEquals( smallFirm, actualInteger, 'The sObject Employees should be plucked' );
    }

    private static testMethod void pluckIntegerTest_SObjectField()
    {
        Integer smallFirm = 60;
        Account smallAccount = new Account( NumberOfEmployees = smallFirm );

        Test.startTest();
            Integer actualInteger = Utilities.pluckInteger( Account.NumberOfEmployees, smallAccount );
        Test.stopTest();

        System.assertEquals( smallFirm, actualInteger, 'The sObject Employees should be plucked' );
    }

    private static testMethod void pluckIntegersIgnoresNulls()
    {
        Account smallAccount = new Account();

        Test.startTest();
            Set<Integer> actualIntegers = Utilities.pluckIntegers( FieldRef.build( 'NumberOfEmployees' ), new List<sObject>{ smallAccount } );
        Test.stopTest();

        System.assert( actualIntegers.isEmpty(), 'null values should be ignored' );
    }

    private static testMethod void pluckIntegersTest()
    {
        Integer smallFirm = 75;
        Integer mediumFirm = 90;
        Integer tinyFirm = 2;
        Account smallAccount = new Account( NumberOfEmployees = smallFirm );
        Account mediumAccount = new Account( NumberOfEmployees = mediumFirm );
        Account tinyAccount = new Account( NumberOfEmployees = tinyFirm );

        List<Account> allAccounts = new List<Account>{ smallAccount, mediumAccount, tinyAccount };
        Map<Id, Account> allAccountsMap = new Map<Id, Account>{
            '00Q0000000XXXXX' => smallAccount,
            '00Q0000000XXXXY' => mediumAccount,
            '00Q0000000XXXXZ' => tinyAccount
        };

        Test.startTest();
            Set<Integer> actualIntegersList = Utilities.pluckIntegers( 'NumberOfEmployees', allAccounts );
            Set<Integer> actualIntegersMap = Utilities.pluckIntegers( 'NumberOfEmployees', allAccountsMap );
        Test.stopTest();

        System.assert( actualIntegersList.contains( smallFirm ), 'The sObject Employees should be plucked' );
        System.assert( actualIntegersList.contains( mediumFirm ), 'The sObject Employees should be plucked' );
        System.assert( actualIntegersList.contains( tinyFirm ), 'The sObject Employees should be plucked' );
        System.assert( actualIntegersMap.contains( smallFirm ), 'The sObject Employees should be plucked' );
        System.assert( actualIntegersMap.contains( mediumFirm ), 'The sObject Employees should be plucked' );
        System.assert( actualIntegersMap.contains( tinyFirm ), 'The sObject Employees should be plucked' );
    }

    private static testMethod void pluckIntegersTest_SObjectField()
    {
        Integer smallFirm = 75;
        Integer mediumFirm = 90;
        Integer tinyFirm = 2;
        Account smallAccount = new Account( NumberOfEmployees = smallFirm );
        Account mediumAccount = new Account( NumberOfEmployees = mediumFirm );
        Account tinyAccount = new Account( NumberOfEmployees = tinyFirm );

        List<Account> allAccounts = new List<Account>{ smallAccount, mediumAccount, tinyAccount };
        Map<Id, Account> allAccountsMap = new Map<Id, Account>{
            '00Q0000000XXXXX' => smallAccount,
            '00Q0000000XXXXY' => mediumAccount,
            '00Q0000000XXXXZ' => tinyAccount
        };

        Test.startTest();
            Set<Integer> actualIntegersList = Utilities.pluckIntegers( Account.NumberOfEmployees, allAccounts );
            Set<Integer> actualIntegersMap = Utilities.pluckIntegers( Account.NumberOfEmployees, allAccountsMap );
        Test.stopTest();

        System.assert( actualIntegersList.contains( smallFirm ), 'The sObject Employees should be plucked' );
        System.assert( actualIntegersList.contains( mediumFirm ), 'The sObject Employees should be plucked' );
        System.assert( actualIntegersList.contains( tinyFirm ), 'The sObject Employees should be plucked' );
        System.assert( actualIntegersMap.contains( smallFirm ), 'The sObject Employees should be plucked' );
        System.assert( actualIntegersMap.contains( mediumFirm ), 'The sObject Employees should be plucked' );
        System.assert( actualIntegersMap.contains( tinyFirm ), 'The sObject Employees should be plucked' );
    }

    private static testMethod void pluckIdTest()
    {
        Lead johnny = new Lead( Id = '00Q0000000XXXXX', FirstName = 'Johnny', LastName = 'Five', Company = 'Johnny Co' );

        Test.startTest();
            Id actualId = Utilities.pluckId( 'Id', johnny );
        Test.stopTest();

        System.assertEquals( johnny.Id, actualId, 'The sObject id should be plucked' );
    }

    private static testMethod void pluckIdTest_SObjectField()
    {
        Lead johnny = new Lead( Id = '00Q0000000XXXXX', FirstName = 'Johnny', LastName = 'Five', Company = 'Johnny Co' );

        Test.startTest();
            Id actualId = Utilities.pluckId( Lead.Id, johnny );
        Test.stopTest();

        System.assertEquals( johnny.Id, actualId, 'The sObject id should be plucked' );
    }

    private static testMethod void pluckIdsIgnoresNulls()
    {
        Lead johnny = new Lead();

        Test.startTest();
            Set<Id> actualIds = Utilities.pluckIds( FieldRef.build( 'Id' ), new List<sObject>{ johnny } );
        Test.stopTest();

        System.assert( actualIds.isEmpty(), 'null values should be ignored' );
    }

    private static testMethod void fieldToSObjects()
    {
        final Id OPPTY_1 = '0067000000Us9A1AAJ';
        final Id OPPTY_2 = '0069000000Us7U1AAN';
        OpportunityLineItem oppty1Product1 = new OpportunityLineItem( Id = '00k7000000N0aqdAAB', OpportunityId = OPPTY_1 );
        OpportunityLineItem oppty1Product2  = new OpportunityLineItem( Id = '00k7000000N0aqdAAC', OpportunityId = OPPTY_1 );
        OpportunityLineItem oppty2Product1  = new OpportunityLineItem( Id = '00k7000000N0aqdAAD', OpportunityId = OPPTY_2 );
        Map<Id, Set<sObject>> expectedOpptyToOLI = new Map<Id, Set<sObject>>{ OPPTY_1 => new Set<sObject>{oppty1Product1, oppty1Product2}, OPPTY_2 => new Set<sObject>{oppty2Product1} };

        Test.startTest();
            Map<Id, Set<sObject>> opptyToOLI = Utilities.fieldToSObjects( 'OpportunityId', new List<OpportunityLineItem>{oppty2Product1, oppty1Product1, oppty1Product2});
        Test.stopTest();
        System.assertEquals(2, opptyToOLI.size(), 'There are two distinct opportunity ids in this list of opportunity line items' + opptyToOLI);
        for( Id opptyId : opptyToOLI.keySet() )
        {
            System.assertEquals( true, expectedOpptyToOLI.containsKey( opptyId ) );
            System.assertEquals( expectedOpptyToOLI.get( opptyId ).size(), opptyToOLI.get( opptyId ).size(), 'The number of opportunity line items belonging to this opportunity is' + expectedOpptyToOLI + ':' + opptyToOLI);
            for(sObject oli : expectedOpptyToOLI.get( opptyId ) )
            {
                System.assertEquals( true, opptyToOLI.get( opptyId ).contains( oli ), 'The following opportunity should belong to this opportunity. Opportunity : ' + opptyId + ' oli ' + oli );
            }
        }
    }

    private static testMethod void fieldToSObjects_SObjectField()
    {
        final Id OPPTY_1 = '0067000000Us9A1AAJ';
        final Id OPPTY_2 = '0069000000Us7U1AAN';
        OpportunityLineItem oppty1Product1 = new OpportunityLineItem( Id = '00k7000000N0aqdAAB', OpportunityId = OPPTY_1 );
        OpportunityLineItem oppty1Product2  = new OpportunityLineItem( Id = '00k7000000N0aqdAAC', OpportunityId = OPPTY_1 );
        OpportunityLineItem oppty2Product1  = new OpportunityLineItem( Id = '00k7000000N0aqdAAD', OpportunityId = OPPTY_2 );
        Map<Id, Set<sObject>> expectedOpptyToOLI = new Map<Id, Set<sObject>>{ OPPTY_1 => new Set<sObject>{oppty1Product1, oppty1Product2}, OPPTY_2 => new Set<sObject>{oppty2Product1} };

        Test.startTest();
            Map<Id, Set<sObject>> opptyToOLI = Utilities.fieldToSObjects( OpportunityLineItem.OpportunityId, new List<OpportunityLineItem>{oppty2Product1, oppty1Product1, oppty1Product2});
        Test.stopTest();
        System.assertEquals(2, opptyToOLI.size(), 'There are two distinct opportunity ids in this list of opportunity line items' + opptyToOLI);
        for( Id opptyId : opptyToOLI.keySet() )
        {
            System.assertEquals( true, expectedOpptyToOLI.containsKey( opptyId ) );
            System.assertEquals( expectedOpptyToOLI.get( opptyId ).size(), opptyToOLI.get( opptyId ).size(), 'The number of opportunity line items belonging to this opportunity is' + expectedOpptyToOLI + ':' + opptyToOLI);
            for(sObject oli : expectedOpptyToOLI.get( opptyId ) )
            {
                System.assertEquals( true, opptyToOLI.get( opptyId ).contains( oli ), 'The following opportunity should belong to this opportunity. Opportunity : ' + opptyId + ' oli ' + oli );
            }
        }
    }

    private static testMethod void pluckIdsTest()
    {
        Lead johnny = new Lead( Id = '00Q0000000XXXX1', FirstName = 'Johnny', LastName = 'Five', Company = 'Johnny Co' );
        Lead julie  = new Lead( Id = '00Q0000000XXXX2', FirstName = 'Julie', LastName = 'Five', Company = 'Julie Co' );
        Lead jamby = new Lead( Id = '00Q0000000XXXX3', FirstName = 'Jamby', LastName = 'Five', Company = 'Jamby Co' );

        List<Lead> allLeads = new List<Lead>{ johnny, julie, jamby };
        Map<Id, Lead> allLeadsMap = new Map<Id, Lead>{
            '00Q0000000XXXXX' => johnny,
            '00Q0000000XXXXY' => julie,
            '00Q0000000XXXXZ' => jamby
        };

        Test.startTest();
            Set<Id> actualIdsList = Utilities.pluckIds( 'Id', allLeads );
            Set<Id> actualIdsMap = Utilities.pluckIds( 'Id', allLeadsMap );
        Test.stopTest();

        System.assert( actualIdsList.contains( johnny.Id ), 'The Ids of the sObjects should be plucked' );
        System.assert( actualIdsList.contains( julie.Id ), 'The Ids of the sObjects should be plucked' );
        System.assert( actualIdsList.contains( jamby.Id ), 'The Ids of the sObjects should be plucked' );
        System.assert( actualIdsMap.contains( johnny.Id ), 'The Ids of the sObjects should be plucked' );
        System.assert( actualIdsMap.contains( julie.Id ), 'The Ids of the sObjects should be plucked' );
        System.assert( actualIdsMap.contains( jamby.Id ), 'The Ids of the sObjects should be plucked' );
    }

    private static testMethod void pluckIdsTest_SObjectField()
    {
        Lead johnny = new Lead( Id = '00Q0000000XXXX1', FirstName = 'Johnny', LastName = 'Five', Company = 'Johnny Co' );
        Lead julie  = new Lead( Id = '00Q0000000XXXX2', FirstName = 'Julie', LastName = 'Five', Company = 'Julie Co' );
        Lead jamby = new Lead( Id = '00Q0000000XXXX3', FirstName = 'Jamby', LastName = 'Five', Company = 'Jamby Co' );

        List<Lead> allLeads = new List<Lead>{ johnny, julie, jamby };
        Map<Id, Lead> allLeadsMap = new Map<Id, Lead>{
            '00Q0000000XXXXX' => johnny,
            '00Q0000000XXXXY' => julie,
            '00Q0000000XXXXZ' => jamby
        };

        Test.startTest();
            Set<Id> actualIdsList = Utilities.pluckIds( Lead.Id, allLeads );
            Set<Id> actualIdsMap = Utilities.pluckIds( Lead.Id, allLeadsMap );
        Test.stopTest();

        System.assert( actualIdsList.contains( johnny.Id ), 'The Ids of the sObjects should be plucked' );
        System.assert( actualIdsList.contains( julie.Id ), 'The Ids of the sObjects should be plucked' );
        System.assert( actualIdsList.contains( jamby.Id ), 'The Ids of the sObjects should be plucked' );
        System.assert( actualIdsMap.contains( johnny.Id ), 'The Ids of the sObjects should be plucked' );
        System.assert( actualIdsMap.contains( julie.Id ), 'The Ids of the sObjects should be plucked' );
        System.assert( actualIdsMap.contains( jamby.Id ), 'The Ids of the sObjects should be plucked' );
    }

    private static testMethod void pluckIdsModifySetTest()
    {
        Lead julie  = new Lead( Id = '00Q0000000XXXX2', FirstName = 'Julie', LastName = 'Five', Company = 'Julie Co' );
        Lead jamby = new Lead( Id = '00Q0000000XXXX3', FirstName = 'Jamby', LastName = 'Five', Company = 'Jamby Co' );

        List<Lead> allLeads = new List<Lead>{  julie };

        Test.startTest();
            Set<Id> idsList = Utilities.pluckIds( allLeads );


            idsList.add(jamby.Id);
        Test.stopTest();

        System.assertEquals( 2, idsList.size(), 'The Set returned from Utilities.ids should be modifiable');
    }

    private static testMethod void pluckIdsAssumeIdField()
    {
        Lead jamby = new Lead( Id = '00Q0000000XXXX3', FirstName = 'Jamby', LastName = 'Five', Company = 'Jamby Co' );

        List<Lead> allLeadsList = new List<Lead>{ jamby };
        Map<Id, Lead> allLeadsMap = new Map<Id, Lead>{ '00Q0000000XXXXX' => jamby };

        Test.startTest();
            Set<Id> actualIdsList = Utilities.pluckIds( allLeadsList );
            Set<Id> actualIdsMap = Utilities.pluckIds( allLeadsMap );
        Test.stopTest();

        System.assert( actualIdsList.contains( jamby.Id ), 'The Ids of the sObjects should be plucked from the list' );
        System.assert( actualIdsMap.contains( jamby.Id ), 'The Ids of the sObjects should be plucked from the map' );
    }

    private static testMethod void pluckIdsAssumeIdField_Duplicates()
    {
        final Id DUMMY_LEAD_ID = '00Q0000000XXXX3';
        Lead jamby = new Lead( Id = DUMMY_LEAD_ID, FirstName = 'Jamby', LastName = 'Five', Company = 'Jamby Co' );
        Lead jambyDupe = new Lead( Id = DUMMY_LEAD_ID, FirstName = 'Jamby', LastName = 'Five', Company = 'Jamby Co' );

        List<Lead> allLeadsList = new List<Lead>{ jamby, jambyDupe };

        ListException unexpectedListEx;
        Set<Id> actualIds;
        Test.startTest();
            try
            {
                actualIds = Utilities.pluckIds( allLeadsList );
            }
            catch( ListException listEx )
            {
                unexpectedListEx = listEx;
            }
        Test.stopTest();
        System.assertEquals( null, unexpectedListEx, 'There should be no list exception' );
        System.assert( actualIds.contains( jamby.Id ), 'The Ids of the sObjects should be plucked from the list' );
    }

    private static testMethod void pluckStringTest()
    {
        Lead johnny = new Lead( FirstName = 'Johnny', LastName = 'Five', Company = 'Johnny Co' );

        Test.startTest();
            String actualName = Utilities.pluckString( 'FirstName', johnny );
        Test.stopTest();

        System.assertEquals( johnny.FirstName, actualName, 'The sObject Name should be plucked' );
    }

    private static testMethod void pluckStringTest_SObjectField()
    {
        Lead johnny = new Lead( FirstName = 'Johnny', LastName = 'Five', Company = 'Johnny Co' );

        Test.startTest();
            String actualName = Utilities.pluckString( Lead.FirstName, johnny );
        Test.stopTest();

        System.assertEquals( johnny.FirstName, actualName, 'The sObject Name should be plucked' );
    }

    private static testMethod void pluckStringsIgnoresNulls()
    {
        Lead johnny = new Lead();

        Test.startTest();
            Set<String> actualStrings = Utilities.pluckStrings( FieldRef.build( 'FirstName' ), new List<sObject>{ johnny } );
        Test.stopTest();

        System.assert( actualStrings.isEmpty(), 'null values should be ignored' );
    }

    private static testMethod void pluckStringsTest()
    {
        Lead johnny = new Lead( FirstName = 'Johnny', LastName = 'Five', Company = 'Johnny Co' );
        Lead julie  = new Lead( FirstName = 'Julie', LastName = 'Five', Company = 'Julie Co' );
        Lead jamby = new Lead( FirstName = 'Jamby', LastName = 'Five', Company = 'Jamby Co' );

        List<Lead> allLeads = new List<Lead>{ johnny, julie, jamby };
        Map<Id, Lead> allLeadsMap = new Map<Id, Lead>{
            '00Q0000000XXXXX' => johnny,
            '00Q0000000XXXXY' => julie,
            '00Q0000000XXXXZ' => jamby
        };

        Test.startTest();
            Set<String> actualNamesList = Utilities.pluckStrings( 'FirstName', allLeads );
            Set<String> actualNamesMap = Utilities.pluckStrings( 'FirstName', allLeadsMap );
        Test.stopTest();

        System.assert( actualNamesList.contains( johnny.FirstName ), 'The FirstNames of the sObjects should be plucked' );
        System.assert( actualNamesList.contains( julie.FirstName ), 'The FirstNames of the sObjects should be plucked' );
        System.assert( actualNamesList.contains( jamby.FirstName ), 'The FirstNames of the sObjects should be plucked' );
        System.assert( actualNamesMap.contains( johnny.FirstName ), 'The FirstNames of the sObjects should be plucked' );
        System.assert( actualNamesMap.contains( julie.FirstName ), 'The FirstNames of the sObjects should be plucked' );
        System.assert( actualNamesMap.contains( jamby.FirstName ), 'The FirstNames of the sObjects should be plucked' );
    }

    private static testMethod void pluckStringsTest_SObjectField()
    {
        Lead johnny = new Lead( FirstName = 'Johnny', LastName = 'Five', Company = 'Johnny Co' );
        Lead julie  = new Lead( FirstName = 'Julie', LastName = 'Five', Company = 'Julie Co' );
        Lead jamby = new Lead( FirstName = 'Jamby', LastName = 'Five', Company = 'Jamby Co' );

        List<Lead> allLeads = new List<Lead>{ johnny, julie, jamby };
        Map<Id, Lead> allLeadsMap = new Map<Id, Lead>{
            '00Q0000000XXXXX' => johnny,
            '00Q0000000XXXXY' => julie,
            '00Q0000000XXXXZ' => jamby
        };

        Test.startTest();
            Set<String> actualNamesList = Utilities.pluckStrings( Lead.FirstName, allLeads );
            Set<String> actualNamesMap = Utilities.pluckStrings( Lead.FirstName, allLeadsMap );
        Test.stopTest();

        System.assert( actualNamesList.contains( johnny.FirstName ), 'The FirstNames of the sObjects should be plucked' );
        System.assert( actualNamesList.contains( julie.FirstName ), 'The FirstNames of the sObjects should be plucked' );
        System.assert( actualNamesList.contains( jamby.FirstName ), 'The FirstNames of the sObjects should be plucked' );
        System.assert( actualNamesMap.contains( johnny.FirstName ), 'The FirstNames of the sObjects should be plucked' );
        System.assert( actualNamesMap.contains( julie.FirstName ), 'The FirstNames of the sObjects should be plucked' );
        System.assert( actualNamesMap.contains( jamby.FirstName ), 'The FirstNames of the sObjects should be plucked' );
    }

    
    private static testMethod void uuidTest(){
        Integer uuidLength = 36; //36 characters (32 hex digits + 4 dashes)
        Test.startTest();
            String uuid = Utilities.uuid();
        Test.stopTest();
        System.assertNotEquals(null, uuid, 'UUID should not be null');
        System.assertEquals(uuidLength, uuid.length(), 'UUID should meet length requirements');
    }
}