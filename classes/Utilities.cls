public inherited sharing class Utilities {

    public static String namespace {
        get {
            if (namespace == null) namespace = Utilities.class.getName().contains('.') ? Utilities.class.getName().split('\\.')[0] : '';
            return namespace;
        }
        private set;
    }

    public static String namespaceDot {
        get {
            return String.isNotBlank(namespace) ? (namespace + '.') : '';
        }
    }

    public static String namespaceUnderscore {
        get {
            return String.isNotBlank(namespace) ? (namespace + '__') : '';
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getNamespacedObject(String objectName) {
        return namespaceUnderscore + objectName;
    }

    public static Map<Date, List<sObject>> groupByDates( String field, List<sObject> records )
    {
        return groupByDates(FieldRef.build(field), records);
    }

    public static Map<Date, List<sObject>> groupByDates( SobjectField field, List<sObject> records )
    {
        return groupByDates(FieldRef.build(field), records);
    }

    public static Map<Date, List<sObject>> groupByDates( FieldRef field, List<sObject> records )
    {
        Map<Date, List<sObject>> returnMap = new Map<Date, List<sObject>>();

        for ( sObject record : records )
        {
            Date key = (Date)field.getFrom( record );

            if ( returnMap.containsKey( key ) )
            {
                returnMap.get( key ).add( record );
            }
            else
            {
                returnMap.put( key, new List<sObject>{ record } );
            }
        }

        return returnMap;
    }

    public static Map<DateTime, List<sObject>> groupByDatetimes( String field, List<sObject> records )
    {
        return groupByDatetimes(FieldRef.build(field), records);
    }

    public static Map<DateTime, List<sObject>> groupByDatetimes( SobjectField field, List<sObject> records )
    {
        return groupByDatetimes(FieldRef.build(field), records);
    }

    public static Map<DateTime, List<sObject>> groupByDatetimes( FieldRef field, List<sObject> records )
    {
        Map<DateTime, List<sObject>> returnMap = new Map<DateTime, List<sObject>>();

        for ( sObject record : records )
        {
            DateTime key = (DateTime)field.getFrom( record );

            if ( returnMap.containsKey( key ) )
            {
                returnMap.get( key ).add( record );
            }
            else
            {
                returnMap.put( key, new List<sObject>{ record } );
            }
        }

        return returnMap;
    }

    public static Map<Decimal, List<sObject>> groupByDecimals( String field, List<sObject> records )
    {
        return groupByDecimals(FieldRef.build(field), records);
    }

    public static Map<Decimal, List<sObject>> groupByDecimals( SobjectField field, List<sObject> records )
    {
        return groupByDecimals(FieldRef.build(field), records);
    }

    public static Map<Decimal, List<sObject>> groupByDecimals( FieldRef field, List<sObject> records )
    {
        Map<Decimal, List<sObject>> returnMap = new Map<Decimal, List<sObject>>();

        for ( sObject record : records )
        {
            Decimal key = (Decimal)field.getFrom( record );

            if ( returnMap.containsKey( key ) )
            {
                returnMap.get( key ).add( record );
            }
            else
            {
                returnMap.put( key, new List<sObject>{ record } );
            }
        }

        return returnMap;
    }

    public static Map<Integer, List<sObject>> groupByIntegers( String field, List<sObject> records )
    {
        return groupByIntegers(FieldRef.build(field), records);
    }

    public static Map<Integer, List<sObject>> groupByIntegers( SobjectField field, List<sObject> records )
    {
        return groupByIntegers(FieldRef.build(field), records);
    }

    public static Map<Integer, List<sObject>> groupByIntegers( FieldRef field, List<sObject> records )
    {
        Map<Integer, List<sObject>> returnMap = new Map<Integer, List<sObject>>();

        for ( sObject record : records )
        {
            Integer key = (Integer)field.getFrom( record );

            if ( returnMap.containsKey( key ) )
            {
                returnMap.get( key ).add( record );
            }
            else
            {
                returnMap.put( key, new List<sObject>{ record } );
            }
        }

        return returnMap;
    }

    public static Map<Id, List<sObject>> groupByIds( String field, List<sObject> records )
    {
        return groupByIds(FieldRef.build(field), records);
    }

    public static Map<Id, List<sObject>> groupByIds( SobjectField field, List<sObject> records )
    {
        return groupByIds(FieldRef.build(field), records);
    }

    public static Map<Id, List<sObject>> groupByIds( FieldRef field, List<sObject> records )
    {
        Map<Id, List<sObject>> returnMap = new Map<Id, List<sObject>>();

        for ( sObject record : records )
        {
            Id key = (Id)field.getFrom( record );

            if ( returnMap.containsKey( key ) )
            {
                returnMap.get( key ).add( record );
            }
            else
            {
                returnMap.put( key, new List<sObject>{ record } );
            }
        }

        return returnMap;
    }

    public static Map<String, List<sObject>> groupByStrings( String field, List<sObject> records )
    {
        return groupByStrings(FieldRef.build(field), records);
    }

    public static Map<String, List<sObject>> groupByStrings( SobjectField field, List<sObject> records )
    {
        return groupByStrings(FieldRef.build(field), records);
    }

    public static Map<String, List<sObject>> groupByStrings( FieldRef field, List<sObject> records )
    {
        Map<String, List<sObject>> returnMap = new Map<String, List<sObject>>();

        for ( sObject record : records )
        {
            String key = (String)field.getFrom( record );

            if ( returnMap.containsKey( key ) )
            {
                returnMap.get( key ).add( record );
            }
            else
            {
                returnMap.put( key, new List<sObject>{ record } );
            }
        }

        return returnMap;
    }

    public static Map<Boolean, List<sObject>> groupByBooleans(String field, List<sObject> records) {
        return groupByBooleans(FieldRef.build(field), records);
    }

    public static Map<Boolean, List<sObject>> groupByBooleans(SobjectField field, List<sObject> records) {
        return groupByBooleans(FieldRef.build(field), records);
    }

    public static Map<Boolean, List<sObject>> groupByBooleans(FieldRef field, List<sObject> records) {
        Map<Boolean, List<sObject>> returnMap = new Map<Boolean, List<sObject>>();
        for(sObject record : records) {
            Boolean key = (Boolean)field.getFrom(record);
            if(!returnMap.containsKey(key)) {
                returnMap.put(key, new List<sObject>());
            }
            returnMap.get(key).add(record);
        }
        return returnMap;
    }

    /**
     * Find value corresponding to a specified field path in nested untyped Map or List
     * e.g. field1.field2.field3 => {"field1":{"field2":{"field3":"hello"}} => hello
     * @param fieldPath - path to nested json attribute e.g. "field1.field2.field3" for top, middle, and target fields
     * @param obj - Map or List<Map> untyped object with attributes populated
     * @param keepFoundKey - default true set to false to remove returned values from original object
     * @return Object value found for the corresponding key
     */
    public static Object parseObjectValue(String fieldPath, Object obj) {
        return parseObjectValue(fieldPath, obj, true);
    }

    public static Object parseObjectValue(String fieldPath, Object obj, Boolean keepFoundKey) {
        return parseObjectForKey(fieldPath, obj, keepFoundKey).value;
    }

    /**
     * Recursive function find value corresponding to a specified key in nested map or list
     * of generic attributes
     * @return ParseKeyResult value found for the corresponding key
     */
    private static ParseKeyResult parseObjectForKey(String keyToFind, Object obj, Boolean keepFoundKey) {
        ParseKeyResult result = new ParseKeyResult();
        if (obj instanceof Map<String,Object>) {
            Map<String,Object> objMap = (Map<String,Object>)obj;
            if(objMap.containsKey(keyToFind)) {
                result.value = objMap.get(keyToFind);
                result.isKeyFound = true;

                //delete found value from map to reduce search time future keys
                if (!keepFoundKey &&
                    !(result.value instanceof List<Object>) &&
                    !(result.value instanceof Map<String,Object>)) {
                    objMap.remove(keyToFind);
                }
            } else if (keyToFind.contains('.')) {
                String[] parts = keyToFind.split('\\.');
                String requiredKey = parts.remove(0);
                ParseKeyResult tmp = parseObjectForKey(requiredKey, obj, keepFoundKey);
                if (tmp.isKeyFound) {
                    result = parseObjectForKey(String.join(parts, '.'), tmp.value, keepFoundKey);
                }
            } else {
                for (String objKey : objMap.keySet()) {
                    if (objMap.get(objKey) instanceof List<Object> ||
                        objMap.get(objKey) instanceof Map<String,Object>) {
                            result = parseObjectForKey(keyToFind, objMap.get(objKey), keepFoundKey);
                    }
                    if (result.isKeyFound) { break; }
                }
            }
        } else if(obj instanceof List<Object>) {
            for (Object item : (List<Object>)obj) {
                result = parseObjectForKey(keyToFind, item, keepFoundKey);
                if (result.isKeyFound) { break; }
            }
        }
        return result;
    }
    private class ParseKeyResult {
        Object value;
        Boolean isKeyFound = false;
    }

    public static Object pluck( String field, sObject obj )
    {
        return pluck( FieldRef.build( field ), obj );
    }

    public static Object pluck( Schema.SObjectField field, sObject obj )
    {
        return pluck( FieldRef.build( field ), obj );
    }

    public static Object pluck( FieldRef field, sObject obj)
    {
        return field.getFrom( obj );
    }

    public static Set<Object> pluck( String field, List<sObject> objs )
    {
        return pluck( FieldRef.build( field ), objs );
    }

    public static Set<Object> pluck( Schema.SObjectField field, List<sObject> objs )
    {
        return pluck( FieldRef.build( field ), objs );
    }

    public static Set<Object> pluck( FieldRef field, List<sObject> objs )
    {
        Set<Object> plucked = new Set<Object>();

        for ( sObject obj : objs )
        {
            Object val = pluck( field, obj );
            if ( val != null )
            {
                plucked.add( val );
            }
        }

        return plucked;
    }

    public static Date pluckDate( String field, sObject obj )
    {
        return pluckDate( FieldRef.build( field ), obj );
    }

    public static Date pluckDate( Schema.SObjectField field, sObject obj )
    {
        return pluckDate( FieldRef.build( field ), obj );
    }

    public static Date pluckDate( FieldRef field, sObject obj )
    {
        return (Date)pluck( field, obj );
    }

    public static Set<Date> pluckDates( String field, Map<Id, sObject> objs )
    {
        return pluckDates( FieldRef.build( field ), objs );
    }

    public static Set<Date> pluckDates( Schema.SObjectField field, Map<Id, sObject> objs )
    {
        return pluckDates( FieldRef.build( field ), objs );
    }

    public static Set<Date> pluckDates( FieldRef field, Map<Id, sObject> objs )
    {
        return pluckDates( field, objs.values() );
    }

    public static Set<Date> pluckDates( String field, List<sObject> objs )
    {
        return pluckDates( FieldRef.build( field ), objs );
    }

    public static Set<Date> pluckDates( Schema.SObjectField field, List<sObject> objs )
    {
        return pluckDates( FieldRef.build( field ), objs );
    }

    public static Set<Date> pluckDates( FieldRef field, List<sObject> objs )
    {
        Set<Date> plucked = new Set<Date>();

        for ( sObject obj : objs )
        {
            Date val = pluckDate( field, obj );
            if ( val != null )
            {
                plucked.add( val );
            }
        }

        return plucked;
    }

    public static Datetime pluckDatetime( String field, sObject obj )
    {
        return pluckDatetime( FieldRef.build( field ), obj );
    }

    public static Datetime pluckDatetime( Schema.SObjectField field, sObject obj )
    {
        return pluckDatetime( FieldRef.build( field ), obj );
    }

    public static Datetime pluckDatetime( FieldRef field, sObject obj )
    {
        return (Datetime)pluck( field, obj );
    }

    public static Set<Datetime> pluckDatetimes( String field, Map<Id, sObject> objs )
    {
        return pluckDatetimes( FieldRef.build( field ), objs );
    }

    public static Set<Datetime> pluckDatetimes( Schema.SObjectField field, Map<Id, sObject> objs )
    {
        return pluckDatetimes( FieldRef.build( field ), objs );
    }

    public static Set<Datetime> pluckDatetimes( FieldRef field, Map<Id, sObject> objs )
    {
        return pluckDatetimes( field, objs.values() );
    }

    public static Set<Datetime> pluckDatetimes( String field, List<sObject> objs )
    {
        return pluckDatetimes( FieldRef.build( field ), objs );
    }

    public static Set<Datetime> pluckDatetimes( Schema.SObjectField field, List<sObject> objs )
    {
        return pluckDatetimes( FieldRef.build( field ), objs );
    }

    public static Set<Datetime> pluckDatetimes( FieldRef field, List<sObject> objs )
    {
        Set<Datetime> plucked = new Set<Datetime>();

        for ( sObject obj : objs )
        {
            Datetime val = pluckDatetime( field, obj );
            if ( val != null )
            {
                plucked.add( val );
            }
        }

        return plucked;
    }

    public static Decimal pluckDecimal( String field, sObject obj )
    {
        return pluckDecimal( FieldRef.build( field ), obj );
    }

    public static Decimal pluckDecimal( Schema.SObjectField field, sObject obj )
    {
        return pluckDecimal( FieldRef.build( field ), obj );
    }

    public static Decimal pluckDecimal( FieldRef field, sObject obj )
    {
        return (Decimal)pluck( field, obj );
    }

    public static Set<Decimal> pluckDecimals( String field, Map<Id, sObject> objs )
    {
        return pluckDecimals( FieldRef.build( field ), objs );
    }

    public static Set<Decimal> pluckDecimals( Schema.SObjectField field, Map<Id, sObject> objs )
    {
        return pluckDecimals( FieldRef.build( field ), objs );
    }

    public static Set<Decimal> pluckDecimals( FieldRef field, Map<Id, sObject> objs )
    {
        return pluckDecimals( field, objs.values() );
    }

    public static Set<Decimal> pluckDecimals( String field, List<sObject> objs )
    {
        return pluckDecimals( FieldRef.build( field ), objs );
    }

    public static Set<Decimal> pluckDecimals( Schema.SObjectField field, List<sObject> objs )
    {
        return pluckDecimals( FieldRef.build( field ), objs );
    }

    public static Set<Decimal> pluckDecimals( FieldRef field, List<sObject> objs )
    {
        Set<Decimal> plucked = new Set<Decimal>();

        for ( sObject obj : objs )
        {
            Decimal val = pluckDecimal( field, obj );
            if ( val != null )
            {
                plucked.add( val );
            }
        }

        return plucked;
    }

    public static Integer pluckInteger( String field, sObject obj )
    {
        return pluckInteger( FieldRef.build( field ), obj );
    }

    public static Integer pluckInteger( Schema.SObjectField field, sObject obj )
    {
        return pluckInteger( FieldRef.build( field ), obj );
    }

    public static Integer pluckInteger( FieldRef field, sObject obj )
    {
        return (Integer)pluck( field, obj );
    }

    public static Set<Integer> pluckIntegers( String field, Map<Id, sObject> objs )
    {
        return pluckIntegers( FieldRef.build( field ), objs );
    }

    public static Set<Integer> pluckIntegers( Schema.SObjectField field, Map<Id, sObject> objs )
    {
        return pluckIntegers( FieldRef.build( field ), objs );
    }

    public static Set<Integer> pluckIntegers( FieldRef field, Map<Id, sObject> objs )
    {
        return pluckIntegers( field, objs.values() );
    }

    public static Set<Integer> pluckIntegers( String field, List<sObject> objs )
    {
        return pluckIntegers( FieldRef.build( field ), objs );
    }

    public static Set<Integer> pluckIntegers( Schema.SObjectField field, List<sObject> objs )
    {
        return pluckIntegers( FieldRef.build( field ), objs );
    }

    public static Set<Integer> pluckIntegers( FieldRef field, List<sObject> objs )
    {
        Set<Integer> plucked = new Set<Integer>();

        for ( sObject obj : objs )
        {
            Integer val = pluckInteger( field, obj );
            if ( val != null )
            {
                plucked.add( val );
            }
        }

        return plucked;
    }

    public static Map<Id, Set<sObject>> fieldToSObjects(String field, List<sObject>objs)
    {
        return fieldToSObjects( FieldRef.build( field ), objs );
    }

    public static Map<Id, Set<sObject>> fieldToSObjects(Schema.SObjectField field, List<sObject>objs)
    {
        return fieldToSObjects( FieldRef.build( field ), objs );
    }

    public static Map<Id, Set<sObject>> fieldToSObjects(FieldRef field, List<sObject>objs)
    {
        Map<Id, Set<sObject>> objTosObjects = new Map<Id, Set<sObject>>();
        for( sObject obj : objs )
        {
            Id fieldVal = (Id)field.getFrom( obj );
            if( !objTosObjects.containsKey( fieldVal ) )
                objTosObjects.put( fieldVal, new Set<sObject>() );
            objTosObjects.get( fieldVal ).add( obj );
        }
        return objTosObjects;
    }

    public static Set<Id> pluckIds( List<sObject> objs )
    {
        Map<Id, sObject> objectMap = new Map<Id, sObject>();
        objectMap.putAll( objs );
        return objectMap.keySet().clone();
    }

    public static Set<Id> pluckIds( Map<Id, sObject> objs )
    {
        return pluckIds( objs.values() );
    }

    public static Id pluckId( String field, sObject obj )
    {
        return pluckId( FieldRef.build( field ), obj );
    }

    public static Id pluckId( Schema.SObjectField field, sObject obj )
    {
        return pluckId( FieldRef.build( field ), obj );
    }

    public static Id pluckId( FieldRef field, sObject obj )
    {
        return (Id)pluck( field, obj );
    }

    public static Set<Id> pluckIds( String field, Map<Id, sObject> objs )
    {
        return pluckIds( FieldRef.build( field ), objs );
    }

    public static Set<Id> pluckIds( Schema.SObjectField field, Map<Id, sObject> objs )
    {
        return pluckIds( FieldRef.build( field ), objs );
    }

    public static Set<Id> pluckIds( FieldRef field, Map<Id, sObject> objs )
    {
        return pluckIds( field, objs.values() );
    }

    public static Set<Id> pluckIds( String field, List<sObject> objs )
    {
        return pluckIds( FieldRef.build( field ), objs );
    }

    public static Set<Id> pluckIds( Schema.SObjectField field, List<sObject> objs )
    {
        return pluckIds( FieldRef.build( field ), objs );
    }

    public static Set<Id> pluckIds( FieldRef field, List<sObject> objs )
    {
        Set<Id> plucked = new Set<Id>();

        for ( sObject obj : objs )
        {
            Id val = pluckId( field, obj );
            if ( val != null )
            {
                plucked.add( val );
            }
        }

        return plucked;
    }

    public static String pluckString( String field, sObject obj )
    {
        return pluckString( FieldRef.build( field ), obj );
    }

    public static String pluckString( Schema.SObjectField field, sObject obj )
    {
        return pluckString( FieldRef.build( field ), obj );
    }

    public static String pluckString( FieldRef field, sObject obj )
    {
        return (String)pluck( field, obj );
    }

    public static Set<String> pluckStrings( String field, Map<Id, sObject> objs )
    {
        return pluckStrings( FieldRef.build( field ), objs );
    }

    public static Set<String> pluckStrings( Schema.SObjectField field, Map<Id, sObject> objs )
    {
        return pluckStrings( FieldRef.build( field ), objs );
    }

    public static Set<String> pluckStrings( FieldRef field, Map<Id, sObject> objs )
    {
        return pluckStrings( field, objs.values() );
    }

    public static Set<String> pluckStrings( String field, List<sObject> objs )
    {
        return pluckStrings( FieldRef.build( field ), objs );
    }

    public static Set<String> pluckStrings( Schema.SObjectField field, List<sObject> objs )
    {
        return pluckStrings( FieldRef.build( field ), objs );
    }

    public static Set<String> pluckStrings( FieldRef field, List<sObject> objs )
    {
        Set<String> plucked = new Set<String>();

        for ( sObject obj : objs )
        {
            String val = pluckString( field, obj );
            if ( val != null )
            {
                plucked.add( val );
            }
        }

        return plucked;
    }

    /**
	 * Generate Random UUID
	 */
	public static String uuid() {
		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		return h.SubString(0,8) + '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
    }

    /*
        Parse out Camel Cased strings with no spaces into a String with Spaces
    */
    public static String parseCamelCasedString(String camelCaseInput){
        List<String> parts = camelCaseInput.splitByCharacterTypeCamelCase();
        return string.join(parts, ' ');
    }
}