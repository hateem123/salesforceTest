public class AccountTriggerHandler {
    public static void OnAfterUpdate( List<Account> newAccounts, Map<ID, Account> oldAccountsMap){
        List<Id> accountIds = new List<Id>(); 
        //List<Account> accUpdate = new List<Account>();
        for(Account acc: newAccounts){
            //lets test if missionStatus value has changed to Canceled
            if(acc.MissionStatus__c != oldAccountsMap.get(acc.Id).MissionStatus__c && 
               				acc.MissionStatus__c == 'canceled')
            {
				
                accountIds.add(acc.Id);
               }
        }
        List<Account> accUpdate = [SELECT Id FROM Account WHERE Id IN: accountIds];
        for(Account acc: accUpdate){
            acc.MissionCanceledDate__c = Date.today();
        }
        //update accounts with new MissionCanceledDate__c
        update accUpdate;
        //query all relationships linked to those accounts, because there are potential contacts that should become inactive
        List<AccountContactRelation> acrList = [SELECT Id, ContactId 
                                               FROM AccountContactRelation
                                               WHERE AccountId IN: accountIds];
        List<Id> cntIds = new List<Id>();
        for(AccountContactRelation acr: acrList){
            cntIds.add(acr.ContactId);
        }
        //map of contacts that has at least one canceled account
        Map<Id, Contact> cntMap = new Map<Id, Contact>([SELECT Id, IsActive__c 
                                FROM Contact
                                WHERE Id IN: cntIds]);
        //list of all accounts linked to these the contacts
        List<AccountContactRelation> acrList2 = [SELECT Id, AccountId, ContactId
                                               FROM AccountContactRelation
                                               WHERE ContactId IN: cntIds];
        List<Id> accIds2 = new List<Id>();
        for(AccountContactRelation acr: acrList2){
            accIds2.add(acr.AccountId);
        }
        Map<Id, Account> accountsLinkedToContacts = new Map<Id, Account>([SELECT Id, MissionStatus__c
                                                                         FROM Account
                                                                         WHERE Id IN: accIds2]);
        //this contactIdWithAccountsMap map will make it easy to check if a contact should become inactive
        //contact inactive == all the accounts linked to it have mission canceled now
        Map<Id, List<Account>> contactIdWithAccountsMap = new Map<Id, List<Account>>();
        for(AccountContactRelation acr: acrList2){
            if(contactIdWithAccountsMap.containsKey(acr.ContactId)){
                contactIdWithAccountsMap.get(acr.ContactId).add(accountsLinkedToContacts.get(acr.AccountId));
            }else{
                contactIdWithAccountsMap.put(acr.ContactId, new List<Account>{accountsLinkedToContacts.get(acr.AccountId)});
            }
        }
        Set<Id> cntIdCalloutAPI = new Set<Id>();
        for(Id cntId: contactIdWithAccountsMap.keySet()){
            Contact cnt = cntMap.get(cntId);
            //we only need to check for currently active contacts
            if(cnt.IsActive__c ==true){
                cnt.IsActive__c = false;
                for(Account acc: contactIdWithAccountsMap.get(cntId)){
                    if(acc.MissionStatus__c == 'active'){
                        cnt.IsActive__c = true;
                    }
                }
                if(cnt.IsActive__c == false){
                    //we end up with a contact where IsActive__c == false only if all accounts linked to it
                    //have mission canceled
                    //We add the contactId to the Set to send it to Endpoint
                    cntIdCalloutAPI.add(cnt.Id);
                }
            }
        }
        update cntMap.values();
        //callout a future method to synch
        ApiIntegration.sendPatchCallout(cntIdCalloutAPI);
        
        
        
    }
}