public with sharing class CandidateTriggerHandler {
	
	public static void setScoreOnStatusUpdate(List<Candidate__c> canNewList) {
		if(!canNewList.isEmpty()) {
			for(Candidate__c canNew: canNewList) {
				if(canNew.Status__c == 'Selected') {
					canNew.Score__c = 10;
				} else if(canNew.Status__c == 'Rejected') {
					canNew.Score__c = -5;
				} else {
					canNew.Score__C = 0;
				}
			} 
		}	
	}
	
    public static void setTotalScoreOnStatusUpdate(Map<Id, Candidate__c> canNewMap, Map<Id, Candidate__c> canOldMap) {
        Set<Id> hiringIdsSet = new Set<Id>();
        if(!canNewMap.isEmpty()) {
            for(Candidate__c canNew: canNewMap.values()) {
                if(canNew.Status__c != canOldMap.get(canNew.id).Status__c && canNew.Hiring__c != null) {
                    hiringIdsSet.add(canNew.Hiring__c);
                }
                
            } 
        }
		updateHiringRecords(hiringIdsSet);
    }
	
	public static void updateHiringRecords(Set<Id> hiringIdsSet) {
		if(hiringIdsSet.isEmpty()) {
			return;
		}
		List<Hiring__c> updateHrList = new List<Hiring__c>();
		List<AggregateResult> agResultList = [SELECT Sum(Score__c) totalScore, AVG(Score__c) avgScore, Hiring__c  
						FROM Candidate__c WHERE Hiring__c =: hiringIdsSet AND Status__c IN ('Selected', 'Rejected') WITH USER_MODE Group By Hiring__c LIMIT 10000 ];
		
		if(!agResultList.isEmpty()) {
			for(AggregateResult ag: agResultList) {
				Hiring__c hr = new Hiring__c();
				hr.Id = (Id)ag.get('Hiring__c');
				hr.Total_Score__c = (Decimal)ag.get('totalScore');
				hr.Average_Score__c = (Decimal)ag.get('avgScore');
				updateHrList.add(hr);
			}
		}
		
		if(!updateHrList.isEmpty()) {
            try {
                if(Schema.SObjectType.Hiring__c.isUpdateable()) {
                    Database.update (updateHrList, AccessLevel.USER_MODE);
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
            
		}
	}
}