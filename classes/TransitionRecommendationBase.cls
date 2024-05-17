/**
 * Base definition of properties for an TransitionRecommendation
 * and required method for generating an TransitionRecommendation instance
 */
public inherited sharing abstract class TransitionRecommendationBase implements Comparable {
    //Severity levels for grouping recommendations
    public Enum SeverityLevel {
        CRITICAL,
        INFO,
        SUCCESS,
        WARNING
    }

    //TransitionRecommendation base instance properties
    public String text = '';
    public List<String> reasons = new List<String>();
    public Integer complexity = 0;
    public SeverityLevel severity = SeverityLevel.INFO;

    //assist sorting
    private static final Map<SeverityLevel,Integer> SEVERITY_SORT_INDEX_MAP = new Map<SeverityLevel,Integer> {
        SeverityLevel.CRITICAL => 1,
        SeverityLevel.WARNING => 2,
        SeverityLevel.INFO => 3,
        SeverityLevel.SUCCESS => 4
    };

    /**
     * Reuired methods to generate recommendation
     * @param assessmentId - Id of Assessment__c record if needed
     */
    public abstract TransitionRecommendation generate(Id assessmentId);

    /**
     * Sort method ASC severity index
     */
    public Integer compareTo(Object compareTo) {
        TransitionRecommendationBase compareToObj = (TransitionRecommendationBase)compareTo;
        if (SEVERITY_SORT_INDEX_MAP.get(this.severity) == SEVERITY_SORT_INDEX_MAP.get(compareToObj.severity)) return 0;
        if (SEVERITY_SORT_INDEX_MAP.get(this.severity) > SEVERITY_SORT_INDEX_MAP.get(compareToObj.severity)) return 1;
        return -1;      
    }
}