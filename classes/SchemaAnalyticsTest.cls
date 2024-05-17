@IsTest
private class SchemaAnalyticsTest {

	private static final Integer TOTAL_ACCOUNTS = 20;
	private static final String MASTER_RECORD_TYPE = SchemaAnalytics.MASTER_RECORD_TYPE;

	@TestSetup
	static void makeData(){
		List<Account> accounts = new List<Account>();

		for(Integer x = 0; x < TOTAL_ACCOUNTS; x++){
			Account account = new Account(
				Name = 'Test Account ' + x
			);
			accounts.add(account);
		}

		insert accounts;
	}

	//This could be a problem... curious to test in enterprise sandbox with record types on Account
	@IsTest
	static void testRecordTypeCountForMaster(){
		Test.startTest();

		Map<String, Integer> recordTypeIdToCount = SchemaAnalytics.getRecordCountByRecordType('Account');

		Test.stopTest();

		System.assertEquals(TOTAL_ACCOUNTS, recordTypeIdToCount.get(MASTER_RECORD_TYPE), 'Expected to have record count with no record types');

	}
}